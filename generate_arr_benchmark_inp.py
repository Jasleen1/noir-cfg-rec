import sys

array_len_from_sys = 2**int(sys.argv[1])
locs_len_from_sys = 2**int(sys.argv[2])


arr = [i for i in range(array_len_from_sys)]
locs = [j%array_len_from_sys for j in range(locs_len_from_sys)]
vals = [j%array_len_from_sys for j in range(locs_len_from_sys)]

print("locs = " + str(locs) + "\n")
print("arr = " + str(arr) + "\n")
print("vals = " + str(vals))