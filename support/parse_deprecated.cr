require "yaml"

file_name = ""
outfile = "config/deprecated.yml"
results = {
  "QTableWidgetItem" => {
    "ignore_methods" => ["operator<"],
  },
  "QListWidgetItem" => {
    "ignore_methods" => ["operator<"],
  },
  # "QUrl" => {
  #   "ignore_methods" => [
  #     "toCFURL",
  #     "fromCFURL",

  #   ],
  # }
}

File.write(outfile, results.to_yaml)

data = Array(Tuple(Int32, String)).new
output = `crystal run support/generate_bindings.cr 2>&1`
output.split("\n").each do |line|
  next unless line =~ /is deprecated/
  if line =~ /(qt_binding_.+\.cpp):(\d+):\d+: warning: '(\w+)'.*/
    file_name = "ext/#{$1}" if file_name.empty?
    data << {$2.to_i, $3}
  end
end

data.each do |pair|
  ln_num = pair[0].as(Int32)
  method = pair[1].as(String)

  lines = `sed -n -e #{ln_num - 1},#{ln_num + 1}p #{file_name}`
  if lines =~ /(Q\w+)_#{method}/
    klass = $1
    results[klass] = {"ignore_methods" => Array(String).new} unless results[klass]?
    results[klass]["ignore_methods"] << method
  end
end

results.each do |_, v|
  v["ignore_methods"].uniq!
end

pp results

File.write(outfile, results.to_yaml)
