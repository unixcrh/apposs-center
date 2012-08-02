概述
====
apposs依赖外部系统（例如CMDB）获得运维所需的基础数据，所以真实场景下应该编写adapter将自己的基础数据模型映射到 apposs 的模型上

接口约定
========
adapter模块本身需要提供下列模块：

* MachineLoader
    * load(*app_id): 传入指定的一组 app_id ，更新这些应用所涉及的机器信息
    * load_all: 更新全部机器信息（可能同时更新应用）
* AppLoader
    * load: 更新全部应用信息
* Auth
    * sso_auth: 当Auth模块include到controller以后，可以直接设定 before_filter 为 sso_auth ，通过相应的认证机制进行后设定 session[:user_id] 

使用说明
========
adapter模块名称将被配置到configuration中，使用者可以用 Rails.configuration.adapter 来引用
