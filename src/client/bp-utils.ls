@BP ||= {}
# 注意，这个方法会一直在每次event quene里尝试，直到找到obj，所以，慎用！
until-obj-available-timer = null
BP.until-obj-available = (obj-str, fn, args)->
  clear-timeout until-obj-available-timer if until-obj-available-timer
  console.log "****** obj-str ....", obj-str
  obj = eval obj-str
  console.log "****** obj ....", obj
  if obj
    fn.apply obj, args
  else
    console.log "****** wait ...."
    until-obj-available-timer = set-timeout  ->
      BP.until-obj-available obj-str, fn, args
