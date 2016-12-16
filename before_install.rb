os = ENV.fetch('TRAVIS_OS_NAME')
os = os.first if os.is_a?(Array)
if %w(linux osx).include?(os)
  `sh before_install_#{os}.sh`
else
  fail "invalid build os: #{os.inspect}"
end
