SimpleCov.start do
  if ENV['CIRCLE_ARTIFACTS']
    dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
    coverage_dir(dir)
  end
  add_filter "/spec/"
end
