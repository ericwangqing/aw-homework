components = # array of components
relations = # array of relations

component = # grunt jade过程中解析出来的component定义，然后Meteor启动时，根据它进行初始化。
  component-class-name: 'xxxx' # 当这一属性存在时，b+将使用这个类，而不是默认的List-Component或Detail-Component类来实例化，这是最终极的定制手段
  doc-name: assignment
  namespace: # nampespace, component-name
  is-main-nav: true

relation = 
  namespace: 'xxx'
  from: 'assignment'
  to: 'homework'
  description: '1 -> *'
  type: 'composition'