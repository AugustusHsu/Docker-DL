# XRDP+Anaconda+Deep Learning in Docker

For the requirement of my lab, I use ubuntu and XRDP to build a virtual environment that can use GUI on it.
And also I need to assign GPU resources to different people.
I follow the tutorial from [Nvidia Docker](https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)) to build the docker, so I can assign GPU to the different user.
Also, I use Anaconda to manager my python packages.

## Build or Pull

### Build

```bash
sudo docker build -t image_name:tag \
--build-arg USERNAME=username \
--build-arg USERPWD=yourpassword .
```

You can change the `USERNAME` and `USERPWD` by yourself. Or use the default setting on this image.

### Pull

```bash
docker pull augustushsu/ubuntu18.04-xrdp:cuda10.0-cudnn7-anaconda
```

Use this command to download image from `Docker Hub`.

## Run

```bash
sudo docker run --gpus device=1 -it \
-p 33890:3389 \
-v /mnt/SSD:/data/SSD \
-v /mnt/HDD:/data/HDD \
-v /docker_config/config:/config \
image_name:tag
```

`--gpus device`：Chose your GPU device. Or use `all`.

`-p`：This is port number on your host to container. `host port : container port`

`-v`：For the directory of your host to the container. `host directory : container port`

For the default：
`USERNAME` is `username`
`USERPWD` is `yourpassword`

Before login, you need to use this command to start the `xrdp` service.

```bash
service xrdp restart
```

## Test

You can find the script on the `username` home directory named `tf2.sh` and `test_tf.py`.

`tf2.sh` can create the `tf2` enviroment and install `Tensorflow2.0`.

`test_tf.py` is a simple neural network on the [Tensorflow website](https://www.tensorflow.org/tutorials/quickstart/beginner). Let you can simply test the environment.

## My Blog

You can find the detail on my Blog, but it is used in Chinese.

https://augustushsu.github.io/2019/12/23/DeepLearning-03/#more

