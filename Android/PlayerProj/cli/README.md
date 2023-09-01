vap-cli
---

# 使用教程
1. 获取 jar

  - 方法一：[下载执行文件](https://github.com/Tencent/vap/raw/master/Android/PlayerProj/cli/build/libs/cli-1.0.jar)

  - 方法2️二：使用 gradle 编译出 jar 产物
    > 要提前编译 animtool
    > 
    > jar 产物默认在 `Android/PlayerProj/cli/build/libs/cli-1.0.jar`

2. 执行 jar

示例：
```bash
java -jar cli-1.0.jar \
  --ffmpeg /path/to/mac/ffmpeg \
  --mp4edit /path/to/mac/mp4edit \
  -i /path/to/test_demo/simple_demo
```
