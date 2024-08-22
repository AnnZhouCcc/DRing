import multiprocessing as mp
import subprocess as sp
import argparse
from tqdm import tqdm
import os
import time
from psutil import virtual_memory

# Safety margin (1GB) in bytes so that the system doesn't crash or switches to swap
# SAFETY_MARGIN = 1024**3
# SAFETY_MARGIN = 1e9

pbar = tqdm (smoothing=0, ncols=80)

def run_thread (conf):
    cmd = conf
    proc = sp.Popen(cmd, shell=True)
    proc.wait()

    # cmd = conf.split (',')[0]
    # output = conf.split (',')[1].split ('\n')[0]
    # if not os.path.exists (os.path.split(output)[0]):
    #     os.makedirs (os.path.split(output)[0])
    # proc = sp.Popen ("./waf --run-no-build " + cmd + " > " + output + " 2>&1", shell=True)
    # proc.wait ()


def pbar_update (*a):
    pbar.update ()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument ('--conf')
    parser.add_argument ('--worker', type=int, default=int (mp.cpu_count () * 0.9))
    parser.add_argument ('--maxGB', type=float)
    parser.add_argument ('--waitSec', type=float)
    args = parser.parse_args ()

    SAFETY_MARGIN = args.maxGB*2*1e9

    # proc = sp.Popen ("./oblivious_c2s_discover.sh", shell=True)
    # proc.wait ()

    with open (args.conf, 'r') as f:
        confs = f.readlines ()
    pbar.reset (total=len (confs))
    pool = mp.Pool (args.worker)
    for conf in confs:
        while True:
            if virtual_memory().available > args.maxGB*1.5*1e9 + SAFETY_MARGIN:
                print(f"Starting {conf}... with {virtual_memory().available} available memory")
                pool.apply_async (run_thread, (conf, ), callback=pbar_update)
                time.sleep(args.waitSec)
                break
            else:
                print(f"Waiting, insufficient memory {virtual_memory().available}")
                time.sleep(60)
    pool.close ()
    pool.join ()
    pbar.close ()