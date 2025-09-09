import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--pwfile", type=str, default="", help="")
parser.add_argument("--numsw", type=int, default=0, help="")

args = parser.parse_args()

pwfile = args.pwfile
numsw = args.numsw







numspine = int(numsw*0.2)
numleaf = int(numsw*0.8)
pw = 1/numspine

with open(pwfile, 'w') as f:
    for fromsw in range(numleaf):
        for tosw in range(numleaf):
            if fromsw != tosw:
                for pid in range(numspine):
                    f.write(f"{fromsw}\t{tosw}\t{pid}\t{fromsw}\t{numleaf+pid}\t{pw}\n")