# gitlab-commands


```
RUNNER

gitlab-runner status
gitlab-runner verify
gitlab-runner stop
gitlab-runner start
gitlab-runner restart

RAKE

gitlab-rake gitlab:check SANITIZE=true
gitlab-rake gitlab:check

gitlab-rake gitlab:sidekiq:stats --trace
gitlab-rake gitlab:sidekiq:check --trace
gitlab-rake gitlab:sidekiq:task --trace

CTL

gitlab-ctl registry-garbage-collect -m
gitlab-ctl stop
gitlab-ctl start
gitlab-ctl restart
gitlab-ctl status

CLI

gitlab-ctl stop && gitlab-runner stop && service docker restart && service gitlab-runner stop && sleep 10 && service gitlab-runner start && gitlab-ctl start && gitlab-runner start

```

Scripts 
```
$ bash purge-jobs.sh "project_id" "token" "https://www.gitlab-XXX.com" "3"
```
