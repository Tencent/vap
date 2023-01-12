<template>
  <div>
    <div ref="anim" class="anim-container"></div>
    <button :class="[!access && 'disable']" @click.stop="play(0)">play(无融合)</button>
    <button :class="[!access && 'disable']" @click.stop="play(1)">play(有融合)</button>
    <button v-if="vap" @click.stop="playContinue()">continue</button>
    <button v-if="vap" @click.stop="pause()">pause</button>
  </div>
</template>

<script>
import Vap from '../../../dist/vap.js'
import config from './demo.json'

export default {
  name: 'vap',
  data () {
    return {
      access: true,
      url: require('./demo.mp4'),
      vap: null
    }
  },
  methods: {
    play (flag) {
      if (!this.access) {
        return
      }
      const that = this
      this.vap = new Vap().play(Object.assign({}, {
        container: this.$refs.anim,
        // 素材视频链接
        src: this.url,
        // 素材配置json对象
        config: config,
        width: 900,
        height: 400,
        // 同素材生成工具中配置的保持一致
        fps: 20,
        // 是否循环
        loop: false,
        // 起始播放时间点
        beginPoint: 0,
        // 精准模式
        accurate: true
        // 播放起始时间点(秒)
      }, flag ? {
        // 融合信息（图片/文字）,同素材生成工具生成的配置文件中的srcTag所对应，比如[imgUser] => imgUser
        imgUser: '//shp.qlogo.cn/pghead/Q3auHgzwzM6TmnCKHzBcyxVPEJ5t4Ria7H18tYJyM40c/0',
        imgAnchor: '//shp.qlogo.cn/pghead/PiajxSqBRaEKRa1v87G8wh37GibiaosmfU334GBWgk7aC8/140',
        textUser: 'user1',
        textAnchor: 'user2',
        type: 2
      } : {type: 1}))
        .on('playing', () => {
          that.access = false
          console.log('playing')
        })
        .on('ended', () => {
          that.access = true
          this.vap = null
          console.log('play ended')
        })
        .on('frame', (frame, timestamp) => {
          // frame: 当前帧(从0开始)  timestamp: (播放时间戳)
          if (frame === 50) {
            // do something
          }
          console.log(frame, '-------', timestamp)
        })
      window.vap = this.vap
    },
    pause () {
      this.vap.pause()
    },
    playContinue () {
      this.vap.play()
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.anim-container {
  width: 900px;
  height: 600px;
  border: 1px solid #cccccc;
  margin: auto;
  margin-bottom: 20px;
}
  button.disable {
    background: gray;
  }
</style>
