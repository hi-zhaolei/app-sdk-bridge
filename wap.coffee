{
  config:
    wrap: 'wap'
    version: ''
  ###*
   * 拼接成search数据
   * @param  {Object} json 需要拼接的数据
   * @return {String}      拼接结果
  ###
  searchJoin: (json)->
    return '' unless toString.call( json ) is '[object Object]'
    search = []
    for k,v of json
      search.push "#{k}=#{v}"
    if search.length
      "?#{search.join('&')}"
    else
      ''
  exec: (name, data, callback)->
    location.href = @sdks[name].method + @searchJoin data
  sdks:
    login:
      method: "http://i.360.cn/login/wap"
}

