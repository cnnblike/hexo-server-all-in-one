###hexo-server-all-in-one
A hexo minimal image to deploy on docker service provider such like [Netease Docker Cloud](https://c.163.com/) or [Hyper.sh](https://hyper.sh/).
Since all these docker service are charged by count and size, and has limited way to change the files from external, I designed this image to be as small as possible and zero dependecy to any environment varible, it contains the following components:
	1. nginx (serve the static files)
	2. openssh (provide ssh service for hexo-git-deployer)
	3. git (provide git service for hexo-git-deployer)
	4. hypervisor (to automatically start nginx and openssh and provide a way to restart nginx with hypervisorctl)

According to my test, this image would took about 59MB memory in total when serving the site only. It's a really good option to do the [64mb challenge](https://news.ycombinator.com/item?id=2644338), if you get interested in it and want to push yourself to the limit, you could try to replace nginx with lighttpd, openssh with dropbear, hypervisor with runit, bash with some shell that comsume less, it well give you some extra memory. 

#### How to build the repository:

First copy your blog.pub (your public key) under the root of this repo, then 
```
docker build -t test:v1 .
```

#### How to use this repository:
In order to get whole control of this image, you actually need two repo, content repo and the config repo.
While the content repo could be generated automatically by the hexo-git-deployer, the another repo that take all the configuration information inside should maintained by yourself.

The info of the content repo you need to put in your git-deployer:

```
deploy:
  type: git
  repo: ssh://root@<your domain>/var/repo/blog.git
  branch: master
  message: "update the content"
  name: <any id you like>
  email: <your email>
```  

After you perform `hexo d`, the git would automatically copy all content (using the post-receive hook) from the blog.git to `/var/www/html`, after that the nginx in the image would automatically restart.

Then what do you need as you config repo?
Just copy the configuration from `/etc/nginx/` that has been written as you needed, then submit the content like the following(under the copied config folder):
```
git init .
git remote add origin ssh://root@<your domain>/var/repo/config.git
git add -A
git commit -m "configuration updated!"
git push -u origin
```
After you perform this, git in the docker would automatically copy all content from config.git to `/etc/nginx` and restart the nginx using `hypervisorctl restart nginx`.

----------

#### We host static sites differently!
Instead of just using the normal hexo routine, to `hexo g && hexo d`, I recommendded you use something else. I'm using a self-hosted Jenkins and Gogs server to control the whole `write-build-deploy` circle, which is amazing! I decoupling the `writing-build-deploy` circle with the `ServeThings` circle. 
You could do that too, you could not only enjoy the benefit of static site (high concurrency), but also the flexibility of dynamic site (editing things anytime everywhere). 
