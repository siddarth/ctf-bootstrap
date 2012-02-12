require 'yaml'
require File.expand_path('proc', File.dirname(__FILE__))

class CTFBootstrap

  def self.run!(config)
    @@config = YAML.load_file(config)
    $DEBUG = 1 if @@config['debug'] == true
    validate_config()
    print_info "setting up #{n} levels"
    setup_users()
  end

  # deletes all users related to ctf.
  def self.delete_all_users(config)
    @@config = YAML.load_file(config)
    print_info "deleting users: #{usernames.join(' ')}..."
    usernames.each { |user| execute("userdel #{user}") }
    print_info "deleted users: #{usernames.join(' ')}."

    print_info "deleting homedirs..."
    usernames.each { |user| execute("rm -rf /home/#{user}") }
    print_info "deleted homedirs."
  end

#  private

  def self.validate_config()
    reqs = ['debug', 'num_levels', 'code_path', 'passwords']
    reqs.each do |req|
      print_error("missing required config option #{req}") if @@config[req].nil?
    end
  end

  # create users, set up passwords
  def self.setup_users()
    print_info "creating users..."
    usernames.each do |user|
      execute("useradd #{user}")
    end

    print_info "creating user home dirs..."
    usernames.each do |user|
      execute("mkdir /home/#{user}")
      execute("chown #{user} /home/#{user}")
    end

    usernames.each_with_index do |user, i|
      password = passwords[user]
      password_file = "/home/#{user}/.password"
      execute("echo #{password} > #{password_file}")
      execute("chown #{user} #{password_file}")
      execute("chmod 600 #{password_file}")
    end
    print_info "users created: #{usernames.join(', ')}..."

    input = passwords.map { |u, p| "#{u}:#{p}" }.join("\n")
    print_info "setting up user passwords..."
    Subprocess.popen('chpasswd', {:stdin => Subprocess::PIPE}) do |p, i, o, e|
      i.write("#{input}\n")
      i.close()
    end
    print_info "passwords set..."
  end

  # set up code
  def self.setup_levels()

  end

  # execute a command depending on debug mode
  # using the subprocess module in proc.rb
  def self.execute(cmd, opts = {})
      print_info("running command '#{cmd}'...")
      out = 42
      unless $DEBUG
        begin
          out = Subprocess.run(cmd, opts)
          print_cmd_error(cmd, out[2]) if out[2] != ''
          out
        rescue Exception => e
          print_cmd_error(cmd, e.message)
        end
      end
      out
  end

  # config stuff

  def self.n; @@config['num_levels'] end

  def self.usernames; (1..n).to_a.map { |n| "level%02d" % n } end

  def self.passwords
    passwds = @@config['passwords']
    print_error("Not enough passwords specified in config.") unless passwds.length == n
    password_hash = Hash.new
    usernames.each_with_index { |u, i| password_hash[u] = passwds[i] }
    password_hash
  end


  # debug

  def self.print_info(msg); puts "[info] #{msg}\n" end

  def self.print_cmd_error(cmd, msg)
    print_error("unable to execute command '#{cmd}': #{msg}")
  end

  def self.print_error(msg); puts "[error] #{msg}"; exit(1) end
end
