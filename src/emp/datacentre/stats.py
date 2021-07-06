import os

dir = "./fct_results_705/"

for filename in os.listdir(dir):
    if not filename.endswith("_topo") and not filename.startswith(".DS_Store"):
        simple_filename = filename
        filename = os.path.join(dir, filename)
        with open(filename) as f:
            max_end = 0
            for line in f:
                words = line.split()
                if (len(words) == 5):
                    start = float(words[3])
                    fct = float(words[2])
                    end = start + fct
                    max_end = max(end, max_end)
            print(simple_filename + " " + str(max_end))