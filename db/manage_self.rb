require './config/environment'

room = Room.find_or_create_by_name 'local'

user = User.first

apposs = App.create(name: 'apposs', virtual: true, state: 'running')

{center:'localhost', agent:'127.0.0.1'}.each do |name,host|
  ap = apposs.children.create!(
    name: "apposs_#{name}",  virtual: false, state: 'running'
  )

  user.grant Role::PE, ap

  room.machines.create!(
    name: name, host: host,
    env: ap.envs[:online,true],
    app: ap,
    port: 22, state: 'normal'
  )
end
