###hexo-server-all-in-one
A hexo minimal image to deploy on docker service provider such like [Netease Docker Cloud](https://c.163.com/) or [Hyper.sh](https://hyper.sh/).
Since all these docker service are charged by count and size, and has limited way to change the files from external, I designed this image to be as small as possible and zero dependecy to any environment varible, it contains the following components:
	1. nginx (serve the static files)
	2. openssh (provide ssh service for hexo-git-deployer)
	3. git (provide git service for hexo-git-deployer)
	4. hypervisor (to automatically start nginx and openssh and provide a way to restart nginx with hypervisorctl)

##### How to build the repository:

First copy your public key under the root of this repo, then 
```
docker build -t test .
```

##### How to use this repository:
In order to get whole control of this image, you actually need two repo:
The content repo could be generated automatically by the hexo-git-deployer, while the another repo (configuration repo) should maintained by yourself.

The info of the content repo you need to put in your deployer:

```
deploy:
  type: git
  repo: ssh://root@<your domain>/var/repo/blog.git
  branch: master
  message: "update the content"
  name: <any id you like>
  email: <your email>
```  

Then what do you need as you config repo?
Just copy the configuration from `/etc/nginx/` that has been written as you needed, then submit the content like the following(under the copied config folder):
```
git init .
git remote add origin ssh://root@<your domain>/var/repo/config.git
git add -A
git commit -m "configuration updated!"
git push -u origin
```
