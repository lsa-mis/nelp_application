# lib/tasks/css.rake
namespace :css do
  desc "Build all CSS files"
  task :build do
    active_admin_path = Gem::Specification.find_by_name("activeadmin").gem_dir + "/app/assets/stylesheets"
    command = "sass app/assets/stylesheets:app/assets/builds --style=compressed --load-path=#{active_admin_path}"
    puts "Running CSS build command: #{command}"
    system(command)
  end

  desc "Watch all CSS files for changes"
  task :watch do
    active_admin_path = Gem::Specification.find_by_name("activeadmin").gem_dir + "/app/assets/stylesheets"
    command = "sass app/assets/stylesheets:app/assets/builds --style=compressed --load-path=#{active_admin_path} --watch"
    puts "Watching for CSS changes with command: #{command}"
    system(command)
  end
end
