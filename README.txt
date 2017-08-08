【openresty和lua框架】
2、openresty需要memcached,mysql模块
3、需要设置package_path
4、需要设置共享内存 并且命名为config 
5、需要luajit
6、调试请关闭jit缓存，生产环境请务必打开缓存 jit cache  （lrucache缓存这一条）
7、运维如果不安装openresty，需要单独安装ngx_lua等模块
8、luajit 线上环境每次更改代码（除了共享内存的设置）需要reload nginx 。
10、请根据项目路径设置配置文件路径


----------------------
框架结构：
    |-base 主要请求数据
    |-bin  常用脚本
    |-conf  配置文件
    |-lib  相关工具
    |-msite  对应项目（主要）
    |-models 获取数据
    |-index.lua  入口文件
    |-route.lua  路由实现
    |-access.lua 权限设置
    |-log 日志
    |-init为最基础的配置数据--一般用不到

框架实现功能：
1、路由映射功能
2、配置加载  lua
3、模板解析 
4、错误异常打印 
5、常用函数  /explode/trim/日志log/
6、数据工具  /http封装/mysql/memcached/lrucache/util
7、相关脚本 /nginx重新启动/nginx配置/



最新改版 11/09
    
   1、做了模块化处理/组件处理/
   2、函数封装的更好
   3、配置一律成lua
   4、去掉mvc结构、改成项目结构、共享组件和models、增加了项目扩展和路由扩展、不再局限于controller、控制器不会没地方写
   5、star为组件文件


--https://yq.aliyun.com/articles/44945 ngx内置变量



最新改版 11/11

   1、优化了默认路由
   2、增加了参数路由、解决了路径可以重复的问题、
   3、完善了express的路由风格、喜欢用node的可以转这个框架

























