Handlebars.register-helper 'bs', (attr)-> # 克服Meteor Handlebars不能使用中文key，形如{{中文}}会出错的问题。改用{{bs '中文'}}
  @[attr]
