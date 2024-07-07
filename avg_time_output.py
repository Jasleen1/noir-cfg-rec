from statistics import mean
import sys

fname = sys.argv[1]
arr_size = sys.argv[2]
lookup_size = sys.argv[3]
file  = open(fname)

user_time = []
sys_time = []


lines = file.readlines()

for line in lines:
    # print("Here")
    broken = list(map(lambda x: x.split(), line.split("	")))
    if len(broken[0]) != 0:
        # if broken[1][0].split('m')[0] != '0':
        #     print("Urgh gotta deal")
        if broken[0][0] == 'user':
            min_time = float(broken[1][0].split('m')[0]) * 60
            seconds_time = float(broken[1][0].split('m')[1].replace("s", "")) 
            user_time.append(min_time + seconds_time)
        elif broken[0][0] == 'sys':
            min_time = float(broken[1][0].split('m')[0])
            seconds_time = float(broken[1][0].split('m')[1].replace("s", ""))
            sys_time.append(min_time + seconds_time)
    # print(broken[0])
    # print(broken)

sys_time_mean = mean(sys_time)
user_time_mean = mean(user_time)
total_mean = sys_time_mean + user_time_mean
print(arr_size + ',' + lookup_size + ',' + str(total_mean))

