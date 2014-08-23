#!/usr/bin/env ruby

require 'yaml'

F = ARGV[1]
P = ARGV[2]
A = ARGV[3]

puts "#{P}"
SAMPLES = ARGV[0].to_i

def run(rbin)
  time_new = []

  print "#{rbin}"
  SAMPLES.times do
    print "."
    m = `cd #{F} && time #{rbin} #{P} #{A} 2>&1`
    m =~ /([\d]+):([\d]+.[\d]+)elapsed/
    time_new << $1.to_i * 60 + $2.to_f
  end

  puts ""
  time_new
end

new_gc_time   = run('~/Plain/src/R/bin/Rscript')
baseline_time = run('~/Plain/src/R_baseline/bin/Rscript')

`cd #{F} && perf record -o ./perf.data ~/Plain/src/R/bin/Rscript #{P} #{A}`
r = `cd #{F} && perf report`
r =~ /^[ \t]+([\d]+\.[\d]+)%.*gcMark/
new_gc_mark = $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*gcMarkWrapper/
new_gc_mark += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*gcForward/
new_gc_mark += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*sweepFixedArena/
new_gc_sweep = $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*sweepArena/
new_gc_sweep += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*clear_page_c/
new_gc_kernel = $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*page_fault/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*release_pages/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*free_pcppages_bulk/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*handle_mm_fault/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*page_add_new_anon_rmap/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*__rmqueue/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*unmapped_area_topdown/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*__pagevec_lru_add_fn/
new_gc_kernel += $1.to_f / 100.0
r =~ /^[ \t]+([\d]+\.[\d]+)%.*find_vma/
new_gc_kernel += $1.to_f / 100.0

`cd #{F} && perf record -o ./perf.data ~/Plain/src/R_baseline/bin/Rscript #{P} #{A}`
r = `cd #{F} && perf report`
r =~ /^[ \t]+([\d]+\.[\d]+)%.*R_gc_internal/
baseline_gc = $1.to_f / 100.0

print "."
new_num = `cd #{F} && ~/Plain/src/R/bin/R --verbose --slave -f #{P} --args #{A} 2>&1 | grep GC | wc -l`.to_i
print "."
old_num = `cd #{F} && ~/Plain/src/R_baseline/bin/R --verbose --slave -f #{P} --args #{A} 2>&1 | grep Gar | wc -l`.to_i

new_gc_avg   = new_gc_time.inject(:+) / SAMPLES.to_f
baseline_avg = baseline_time.inject(:+) / SAMPLES.to_f

res = {
  benchmark: P,
  arguments:  A,
  samples: SAMPLES,
  new_runtime: new_gc_time,
  new_runtime_avg: new_gc_avg,
  new_gc_cycles: new_num,
  new_percent_gc_time: new_gc_mark + new_gc_sweep,
  new_percent_marking: new_gc_mark,
  new_percent_sweeping: new_gc_sweep,
  new_percent_kernel_page_fault: new_gc_kernel,
  baseline_runtime: baseline_time,
  baseline_runtime_avg: baseline_avg,
  baseline_gc_cycles: old_num,
  baseline_percent_gc_time: baseline_gc,
  runtime_cmp: new_gc_avg / baseline_avg,
  gc_cycle_cmp: new_num.to_f/old_num.to_f
}

results = YAML::load_file('results.yaml') rescue []
results << res
File.open('results.yaml', 'w') {|f| f.write results.to_yaml }
puts res.to_yaml
