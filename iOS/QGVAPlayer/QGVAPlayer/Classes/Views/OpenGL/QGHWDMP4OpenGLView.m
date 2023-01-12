// QGHWDMP4OpenGLView.m
// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
//
// Licensed under the MIT License (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

#import "QGHWDMP4OpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVUtilities.h>
#import <mach/mach_time.h>
#import <GLKit/GLKit.h>
#import "VAPMacros.h"

// Uniform index.
enum {
    HWD_UNIFORM_Y,
    HWD_UNIFORM_UV,
    HWD_UNIFORM_COLOR_CONVERSION_MATRIX,
    HWD_NUM_UNIFORMS
};
GLint hwd_uniforms[HWD_NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD_RGB,
    ATTRIB_TEXCOORD_ALPHA,
    NUM_ATTRIBUTES
};

// BT.709-HDTV.
static const GLfloat kQGColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

// BT.601 full range-http://www.equasys.de/colorconversion.html
const GLfloat kQGColorConversion601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};


// texture coords for blend

const GLfloat textureCoordLeft[] =  { // 左侧
    0.5, 0.0,
    0.0, 0.0,
    0.5, 1.0,
    0.0, 1.0
};

const GLfloat textureCoordRight[] =  { // 右侧
    1.0, 0.0,
    0.5, 0.0,
    1.0, 1.0,
    0.5, 1.0
};

const GLfloat textureCoordTop[] =  { // 上侧
    1.0, 0.0,
    0.0, 0.0,
    1.0, 0.5,
    0.0, 0.5
};

const GLfloat textureCoordBottom[] =  { // 下侧
    1.0, 0.5,
    0.0, 0.5,
    1.0, 1.0,
    0.0, 1.0
};

#undef cos
#undef sin
NSString *const kVertexShaderSource = SHADER_STRING
(
 attribute vec4 position;
 attribute vec2 RGBTexCoord;
 attribute vec2 alphaTexCoord;
 
 varying vec2 RGBTexCoordVarying;
 varying vec2 alphaTexCoordVarying;
 
 void main()
{
    float preferredRotation = 3.14;
    mat4 rotationMatrix = mat4(cos(preferredRotation), -sin(preferredRotation), 0.0, 0.0,sin(preferredRotation),cos(preferredRotation), 0.0, 0.0,0.0,0.0,1.0,0.0,0.0,0.0, 0.0,1.0);
    gl_Position = rotationMatrix * position;
    RGBTexCoordVarying = RGBTexCoord;
    alphaTexCoordVarying = alphaTexCoord;
}
 );

NSString *const kFragmentShaderSource = SHADER_STRING
(
 varying highp vec2 RGBTexCoordVarying;
 varying highp vec2 alphaTexCoordVarying;
 precision mediump float;
 
 uniform sampler2D SamplerY;
 uniform sampler2D SamplerUV;
 uniform mat3 colorConversionMatrix;
 
 void main()
{
    mediump vec3 yuv_rgb;
    lowp vec3 rgb_rgb;
    
    mediump vec3 yuv_alpha;
    lowp vec3 rgb_alpha;
    
    // Subtract constants to map the video range start at 0
    yuv_rgb.x = (texture2D(SamplerY, RGBTexCoordVarying).r);// - (16.0/255.0));
    yuv_rgb.yz = (texture2D(SamplerUV, RGBTexCoordVarying).ra - vec2(0.5, 0.5));
    
    rgb_rgb = colorConversionMatrix * yuv_rgb;
    
    
    yuv_alpha.x = (texture2D(SamplerY, alphaTexCoordVarying).r);// - (16.0/255.0));
    yuv_alpha.yz = (texture2D(SamplerUV, alphaTexCoordVarying).ra - vec2(0.5, 0.5));
    
    rgb_alpha = colorConversionMatrix * yuv_alpha;
    
    
    gl_FragColor = vec4(rgb_rgb,rgb_alpha.r);
    //    gl_FragColor = vec4(1, 0, 0, 1);
}
 );


@interface QGHWDMP4OpenGLView() {

    GLint _backingWidth;
    GLint _backingHeight;
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _textureCache;
    GLuint _frameBufferHandle;
    GLuint _colorBufferHandle;
    const GLfloat *_preferredConversion;
}

@property GLuint program;

- (void)setupBuffers;
- (void)cleanupTextures;

- (BOOL)isValidateProgram:(GLuint)prog;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL;
- (BOOL)linkProgram:(GLuint)prog;

@end

@implementation QGHWDMP4OpenGLView

+ (Class)layerClass {
    
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        if (![self commonInit]) {
            return  nil;
        }
    }
    return self;
}

- (instancetype)init {
    
    if (self = [super init]) {
        if (![self commonInit]) {
            return  nil;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        if (![self commonInit]) {
            return  nil;
        }
    }
    return self;
}

- (BOOL)commonInit {
    
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = NO;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                      kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_glContext || ![EAGLContext setCurrentContext:_glContext] || ![self loadShaders]) {
        return NO;
    }
    _preferredConversion = kQGColorConversion709;
    return YES;
}

- (void)dealloc {
    
    [self cleanupTextures];
    if(_textureCache) {
        CFRelease(_textureCache);
    }
    if ([self.displayDelegate respondsToSelector:@selector(onViewUnavailableStatus)]) {
        [self.displayDelegate onViewUnavailableStatus];
    }
}

# pragma mark - OpenGL setup
/**
 初始化opengl环境
 */
- (void)setupGL {
    
    VAP_Info(kQGVAPModuleCommon, @"setupGL");
    [EAGLContext setCurrentContext:_glContext];
    [self setupBuffers];
    [self loadShaders];
    glUseProgram(self.program);
    glUniform1i(hwd_uniforms[HWD_UNIFORM_Y], 0);
    glUniform1i(hwd_uniforms[HWD_UNIFORM_UV], 1);
    glUniformMatrix3fv(hwd_uniforms[HWD_UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    // Create CVOpenGLESTextureCacheRef for optimal CVPixelBufferRef to GLES texture conversion.
    if (!_textureCache) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &_textureCache);
        if (err != noErr) {
            VAP_Event(kQGVAPModuleCommon, @"Error at CVOpenGLESTextureCacheCreate %d", err);
            return;
        }
    }
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

#pragma mark - Utilities

- (void)setupBuffers {
    
    glDisable(GL_DEPTH_TEST);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_RGB);
    glVertexAttribPointer(ATTRIB_TEXCOORD_RGB, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_ALPHA);
    glVertexAttribPointer(ATTRIB_TEXCOORD_ALPHA, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), 0);
    glGenFramebuffers(1, &_frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    glGenRenderbuffers(1, &_colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        VAP_Event(kQGVAPModuleCommon, @"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self updateBackingSize];
}


/**
 根据容器大小更新渲染尺寸
 */
- (void)updateBackingSize {
    
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
}

- (void)cleanupTextures {
    
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
}

#pragma mark - OpenGLES drawing

/**
 上屏
 
 @param pixelBuffer 硬解出来的samplebuffer数据
 */
- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    if (!self.window && [self.displayDelegate respondsToSelector:@selector(onViewUnavailableStatus)]) {
        [self.displayDelegate onViewUnavailableStatus];
        return ;
    }
    
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
    
    CVReturn err;
    if (pixelBuffer != NULL) {
        int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        
        if (!_textureCache) {
            VAP_Event(kQGVAPModuleCommon, @"No video texture cache");
            return;
        }
        [self cleanupTextures];

        _preferredConversion = kQGColorConversion601FullRange;
        
        //y
        glActiveTexture(GL_TEXTURE0);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _textureCache,
                                                           pixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_LUMINANCE,
                                                           frameWidth,
                                                           frameHeight,
                                                           GL_LUMINANCE,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &_lumaTexture);
        if (err) {
            VAP_Event(kQGVAPModuleCommon, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // uv
        glActiveTexture(GL_TEXTURE1);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _textureCache,
                                                           pixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_LUMINANCE_ALPHA,
                                                           frameWidth / 2.0,
                                                           frameHeight / 2.0,
                                                           GL_LUMINANCE_ALPHA,
                                                           GL_UNSIGNED_BYTE,
                                                           1,
                                                           &_chromaTexture);
        if (err) {
            VAP_Error(kQGVAPModuleCommon, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d",  err);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
        
        // Set the view port to the entire view.
        glViewport(0, 0, _backingWidth, _backingHeight);
    }
    
    //    glClearColor(0.1f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.program);
    glUniformMatrix3fv(hwd_uniforms[HWD_UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    
    // 根据视频的方向和高宽比设置四个顶点。
    CGRect vertexRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(_backingWidth, _backingHeight), self.layer.bounds);
    
    // 计算归一化四坐标来绘制坐标系。
    CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
    CGSize cropScaleAmount = CGSizeMake(vertexRect.size.width/self.layer.bounds.size.width, vertexRect.size.height/self.layer.bounds.size.height);
    
    if (cropScaleAmount.width > cropScaleAmount.height) {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.height/cropScaleAmount.width;
    } else {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.width/cropScaleAmount.height;
    }
    
    GLfloat quadVertexData [] = {
        -1 * normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        -1 * normalizedSamplingSize.width, normalizedSamplingSize.height,
        normalizedSamplingSize.width, normalizedSamplingSize.height,
    };
    
    // 更新顶点数据
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, quadVertexData);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXCOORD_RGB, 2, GL_FLOAT, 0, 0, [self quadTextureRGBData]);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_RGB);
    glVertexAttribPointer(ATTRIB_TEXCOORD_ALPHA, 2, GL_FLOAT, 0, 0, [self quedTextureAlphaData]);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD_ALPHA);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    if ([EAGLContext currentContext] == _glContext && !self.pause && self.window && [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
}

- (const void *)quedTextureAlphaData {

    switch (self.blendMode) {
        case QGHWDTextureBlendMode_AlphaLeft:
            return textureCoordLeft;
        case QGHWDTextureBlendMode_AlphaRight:
            return textureCoordRight;
        case QGHWDTextureBlendMode_AlphaTop:
            return textureCoordTop;
        case QGHWDTextureBlendMode_AlphaBottom:
            return textureCoordBottom;
        default:
            return textureCoordLeft;
    }
}

- (const void *)quadTextureRGBData {

    switch (self.blendMode) {
        case QGHWDTextureBlendMode_AlphaLeft:
            return textureCoordRight;
        case QGHWDTextureBlendMode_AlphaRight:
            return textureCoordLeft;
        case QGHWDTextureBlendMode_AlphaTop:
            return textureCoordBottom;
        case QGHWDTextureBlendMode_AlphaBottom:
            return textureCoordTop;
        default:
            return textureCoordRight;
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders {
    
    GLuint vShader, fShader;
    self.program = glCreateProgram();
    // Create and compile the vertex shader.
    if (![self compileShader:&vShader type:GL_VERTEX_SHADER source:kVertexShaderSource]) {
        VAP_Error(kQGVAPModuleCommon, @"Failed to compile vertex shader");
        return NO;
    }
    // Create and compile fragment shader.
    if (![self compileShader:&fShader type:GL_FRAGMENT_SHADER source:kFragmentShaderSource]) {
        VAP_Error(kQGVAPModuleCommon, @"Failed to compile fragment shader");
        return NO;
    }
    // Attach vertex shader to program.
    glAttachShader(self.program, vShader);
    // Attach fragment shader to program.
    glAttachShader(self.program, fShader);
    // Bind attribute locations. This needs to be done prior to linking.
    glBindAttribLocation(self.program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(self.program, ATTRIB_TEXCOORD_RGB, "RGBTexCoord");
    glBindAttribLocation(self.program, ATTRIB_TEXCOORD_ALPHA, "alphaTexCoord");
    // Link the program.
    if (![self linkProgram:self.program]) {
        VAP_Event(kQGVAPModuleCommon, @"Failed to link program: %d", self.program);
        if (vShader) {
            glDeleteShader(vShader);
            vShader = 0;
        }
        if (fShader) {
            glDeleteShader(fShader);
            fShader = 0;
        }
        if (self.program) {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        return NO;
    }
    
    // Get uniforms' location.
    hwd_uniforms[HWD_UNIFORM_Y] = glGetUniformLocation(self.program, "SamplerY");
    hwd_uniforms[HWD_UNIFORM_UV] = glGetUniformLocation(self.program, "SamplerUV");
    hwd_uniforms[HWD_UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(self.program, "colorConversionMatrix");
    
    // Release vertex and fragment shaders.
    if (vShader) {
        glDetachShader(self.program, vShader);
        glDeleteShader(vShader);
    }
    if (fShader) {
        glDetachShader(self.program, fShader);
        glDeleteShader(fShader);
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(const NSString *)sourceString {
    
    GLint status;
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
#if defined(DEBUG)
    GLint lengthOfLog;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &lengthOfLog);
    if (lengthOfLog > 0) {
        GLchar *log = (GLchar *)malloc(lengthOfLog);
        glGetShaderInfoLog(*shader, lengthOfLog, &lengthOfLog, log);
        VAP_Info(kQGVAPModuleCommon, @"MODULE_DECODE Shader compile log:\n%s", log)
        free(log);
    }
#endif
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL {
    
    VAP_Info(kQGVAPModuleCommon, @"compileShader");
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
    if (sourceString == nil) {
        VAP_Event(kQGVAPModuleCommon, @"Failed to load vertex shader: %@", [error localizedDescription]);
        return NO;
    }
    
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint lengthOfLog;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &lengthOfLog);
    if (lengthOfLog > 0) {
        GLchar *log = (GLchar *)malloc(lengthOfLog);
        glGetShaderInfoLog(*shader, lengthOfLog, &lengthOfLog, log);
        VAP_Info(kQGVAPModuleCommon, @"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog {
    
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint lengthOfLog;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &lengthOfLog);
    if (lengthOfLog > 0) {
        GLchar *log = (GLchar *)malloc(lengthOfLog);
        glGetProgramInfoLog(prog, lengthOfLog, &lengthOfLog, log);
        VAP_Info(kQGVAPModuleCommon, @"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isValidateProgram:(GLuint)prog {
    
    GLint logLength, status;
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        VAP_Info(kQGVAPModuleCommon, @"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        VAP_Event(kQGVAPModuleCommon, @"program is not valid:%@",@(status));
        return NO;
    }
    VAP_Info(kQGVAPModuleCommon, @"programe is valid");
    return YES;
}

- (void)dispose {
    
    glDisableVertexAttribArray(ATTRIB_VERTEX);
    glDisableVertexAttribArray(ATTRIB_TEXCOORD_RGB);
    glDisableVertexAttribArray(ATTRIB_TEXCOORD_ALPHA);
}

@end
