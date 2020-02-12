## INSTRUCTIONS TO BUILD AND RUN THE DEMO:

1) get source
```
git clone boardion
cd boardion
```

2) compile preprocess program in standalone
```
cd ./preprocess
g++ -static-libgcc -static-libstdc++ -O3 -Wall --std=c++17 -I ./include/ -o ../demo/boardion_preprocess -D DOCTEST_CONFIG_DISABLE ./src/*.cpp -lstdc++fs
cd ..
```

3) build docker image
```
docker build -t demo-boardion -f ./demo/dockerfile .
```

4) Run docker demo
input_data folder must contain only sequencing_summary, they will be slowly copied to simulate the sequecing process
finished_run folder must contain sequencing_summary with their final_summary
```
docker run -itp 80:80 -v input_data:/usr/home/root/demo/raw:z -v finished_run:/usr/home/root/demo/data:z demo-boardion
```
