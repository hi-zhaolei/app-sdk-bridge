factory = ->
  # 统一配置
  config =
    debug: location.href.indexOf('debug=1') > -1

  config =
    debug: no
  appMatchMap =
    '360around': '360around'
    'mobilesafe wallet': '360safe'
    'mso': 'mso'

  ASSERT =
    isString: (v)-> toString.apply(v) is '[object String]'
    isArray: (v)-> toString.apply(v) is '[object Array]'
    isObject: (v)-> toString.apply(v) is '[object Object]'

  ###*
   * 数据打印，默认alert
  ###
  log = (msg)-> alert msg
  ###*
   * 客户端系统判定
   * @return {type} [description]
  ###
  setConfig = (conf) ->
    unless conf.appkey
      log 'Error: appkey is empty'
      throw "appkey is empty"
    config['appkey'] = conf.appkey || "";
    config['debug'] = conf.debug || false;
    if config.debug
      log 'config is ' + JSON.stringify(config)
  ###*
   * 客户端系统判定
   * @return {type} [description]
  ###
  systemConfirm = ->
    if ua.indexOf('iPhone') > -1
      return 'ios'
    if ua.indexOf('Android') > -1
      return 'android'
    'other'
  ###*
   * 版本数据计算
   * @param  {String} _ver 需要换算的版本号
   * @return {Number}      版本换算结果
  ###
  versionConvert = (_ver) ->
    return 0 unless _ver
    _tmp_arr = _ver.split '.'
    ((_tmp_arr[0] - 1 ) * 10 * 10 * 10000 ) + (_tmp_arr[1] * 10 * 10000 ) + (_tmp_arr[2] * 10000 ) + _tmp_arr[3] - 1000
  ###*
   * 调用app`s sdk
   * @param  {String} method 需要调用的app方法
   * @return {Boolean}       调用结果
  ###
  exec = ( name, data, callback )->
    ###
      app对应的sdk配置缺失
    ###
    return log "#{base.app}sdk没有此功能提供" unless has name
    # 参数数组化
    args = arguments.slice 0
    # 获取sdk配置
    sdk = JSBridge.sdks[name]
    ###
      调用app注入的bridge调用appView
    ###
    if ASSERT.isObject sdk
      if versionConvert( base.version ) >= versionConvert sdk.require
        JSBridge.exec.apply JSBridge, args
      else
        log "#{base.app}的当前的版本暂不支持#{name}功能"
      return yes

    ###
      sdk为字符串，web或者sdk通过log通信
    ###
    if ASSERT.isString sdk
      if method.indexOf('http') is 0
        location.href = method + searchJoin data
        log location.href if config.debug
      else
        console.log method + searchJoin data
      return yes
    no
  ###*
   * 匹配在appMap配置内是否有sdk存在
   * @param  {String} sdkName 需要校验的sdk名
   * @return {Boolean}        true sdk存在并且版本匹配 false sdk不存在或存在但是版本不匹配
  ###
  has = (sdkName) -> `sdkName in JSBridge.sdks`

  ###*
   * 初始化数据
   * @type {object}
  ###
  ua = navigator.userAgent
  for match,fileName of appMatchMap
    if ua.indexOf(match) > -1
      configFilePath = "./#{systemConfirm()}/#{fileName}"
  require.ensure configFilePath, ->
    JSBridge = require configFilePath
    config = JSBridge.config
  ###*
   * 对外公开数据和方法
   * @type {object}
  ###
  bridge = {
    config: JSBridge.config
    JSBridge: JSBridge
    exec: exec
    has: has
    geVersion: (v) -> versionConvert( config.version ) >= versionConvert v
  }
###*
 * 兼容多种形式
 * @param  {object} root     =             @ [window object]
 * @param  {[type]} factory= [模块工厂函数]
###
do (root = @, factory = factory) ->
  if typeof define is 'function' and define.amd
    ###*
     * requirejs
    ###
    define 'bridge', [], -> factory()
  else if typeof exports is 'object'
    ###*
     * node or cmd seajs
    ###
    module.exports = factory()
  else
    ###*
     * 全局
    ###
    root.Bridge = factory()
