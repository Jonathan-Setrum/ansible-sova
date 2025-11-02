# sova-serverspec

## Requirements

- [Serverspec 2](http://serverspec.org/)
- ruby (See .ruby-version file for version)
- bundler

## Structure

Put tests in spec directory with following rules.

| Directory name        | Solus | OpenVZ|
|                       | T | I | T | I |
|-----------------------|---------------|
| common                | o | o | o | o |
| common_instance       | - | o | - | o |
| common_openvz         | - | - | o | o |
| common_solusvm        | o | o | - | - |
| common_template       | o | - | o | - |
| openvz_base_template  | - | - | o | - |
| openvz_instance       | - | - | - | o |
| solusvm_base_template | o | - | - | - |
| solusvm_instance      | - | o | - | - |

T: Template, I: Instances

- phpmyadmin and phpmyadmin_disabled are only for instances.
- The directory rule is defined in `scripts/create_serverspec_file.rb`

## How to use

tl;dr  Run tests using Jenkins job.

<http://jenkins.midx.jp/job/sova-instance-test-dadmin/>

----

To run serverspec, you need `rake`.  The command will be installed when you run `bundle install`.

List of all tasks can be created by running `rake -T`

```
$ rake -T
rake serverspec              # Run serverspec on all hosts
rake serverspec:10.1.53.100  # Run serverspec on openvz_template
rake serverspec:182.48.4.5   # Run serverspec on solusvm_template
```

For example, to run the tests for solusvm template:

```
$ rake serverspec:182.48.4.5
```

You can parallelize test with `-j`

```
$ rake -m -j12 serverspec
```
