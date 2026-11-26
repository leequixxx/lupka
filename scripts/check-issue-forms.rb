require "yaml"

root = File.expand_path("..", __dir__)
Dir.chdir(root) do
  paths = Dir[".github/ISSUE_TEMPLATE/*.yml"].sort
  raise "No issue forms found" if paths.empty?

  paths.each do |path|
    document = YAML.safe_load(File.read(path))
    raise "#{path}: root must be a mapping" unless document.is_a?(Hash)
  end
  puts "Checked #{paths.length} issue-form YAML files."
end
