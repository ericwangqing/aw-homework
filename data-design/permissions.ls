# 定义一个process中的角色与权限
# 这里的文件名用permissions，而不是permission-def，因为所有def的东东，运行时多会有factory去创建，会有多个实例，实例间的状态不同
# 而permissions不需要，只要一个就够了，所以名称上区分开来
A-permissions = #定义角色、权限
  _id: 'pmid1'
  permissions:
    * step: "Assign"
      actors: ['Role:Teacher'] # 无前缀Role:的可以是用户id
      viewers: ['Role:Student'] # 能够在这个阶段浏览到data的用户
      collection: 'assignments' # 这里这是为了开发时的可读性，其实运行时是不需要的
      allows: # 注意！！！或者改allow、deny为 invisiable | visible | editable | uneditable ？？
        # * student: 'deadline:update'
          # ...
      denys:
        # 所有collection的_id域界面上均无，除非出现在allow里面
        # * student: 'deadline:update'
          # ...
    * step: 'Write'
      actors: ['Role:Student'] # 无前缀Role:的可以是用户id
      viewers: ['Role:Teacher'] # 能够在这个阶段浏览到data的用户
      collection: 'homeworks'

    * step: 'Score'
      actors: ['Role:Teacher']
      collection: 'homeworks'
