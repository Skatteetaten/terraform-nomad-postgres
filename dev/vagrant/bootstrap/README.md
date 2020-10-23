# Customize the startup procedure of the Hashistack with pre- and post start ansible scripts

You may put any number of script files in this directory for running ansible commands prior to bootstrapping the hashistack.
The bootstrap procedure is included/hardcoded in your box.
[bootstrap.yml](https://github.com/fredrikhgrelland/vagrant-hashistack/blob/master/ansible/bootstrap.yml) will start by running the scripts in this folder and the ones defined in separate folders 
such as vault, consul and nomad.

Each folder should include pre and post folders which specifyies the sequence the scripts are run. See the following structure for a nomad folder:
```sh
 bootstrap
  ├── nomad
  │   ├── post
  │   │   └── 03-example.yml
  │   └── pre
  │       └── 00-example.yml
  └── README.md
```

The files e.g. 0-example.yml must only include pure ansible task syntax:
```yaml
- name: Task that shows usage of prestart
  debug:
    msg: This would be a prestart task
```
