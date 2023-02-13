# podcase

#### 系统分层图

![System](https://user-images.githubusercontent.com/6084259/217453997-0fdf29b9-bcb3-4f1f-b05e-471bb4539061.png)

- Client，选用Flutter 作为开发语言。
- Backend，选用istio作为微服务管理工具，微服务选用golang作为开发语言。
- Storage，DB选用Postgresql, 查询服务使用Elesstic Search。
- Tool, 爬虫选用python作为开发语言。

#### 数据流程图


![dataflow](https://user-images.githubusercontent.com/6084259/217481903-d8933b28-fd7f-4352-9de6-c61e65277371.png)
##### 播客数据流程
- 通过爬虫工具，从网络获取播客数据，然后存储到数据库。
- 通过flinkcdc，将数据分发到ES，以及生成推荐模型的最新数据文件。
- 用golang创建api，提供ES以及recommenddb里面的数据。
- 用Flutter创建app来呈现播客数据。

##### usage 数据流程
- Flutter里面埋点。
- 将Usage数据发送到kafka。
  - 生成最新的usage数据文件。
  - 存到usagedb。
 
 #### 推荐模型
 - TODO
