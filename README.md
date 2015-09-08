# server-hardening

This script can be used to harden a linux server. It is intended
to be easily extendable to include your own checks

## How to run
This is a *really* early alpha and the script unterstands no arguments right
now. So probably best to not run it at all. You have been warned

````bash
git clone git@github.com:stschulte/server-hardening.git
cd server-hardening
export RUBYLIB=`pwd`/lib
bin/harden.rb
````

## A word about Puppet

I developed this as a stand-alone program but I have some ideas in mind to
easily integrate this with puppet, so you can use puppet to make sure your
system is hardened. But why didn't I start with puppet in the first place?

In my opinion the hardening modules that I have seen so far use vanilla (or
stdlib) puppet types to configure your system. This has two drawbacks
* in puppet you manage the desired state of dedicated resources. But some
  hardning rules only specify a small set of attributes. As a result a puppet
  hardning module is often more strict than necessary. Example: According to
  CIS `/tmp` should be mounted with the `noexec` option. The module may now
  say:

  ````puppet
  mount { '/tmp':
    options => 'noexec',
  }
  ````

  While this works, what if `/tmp` is mounted as `tmpfs` and with the specific
  option `-o size=2G`? The above puppet code would simply replace the
  `options`, erasing any prior option.
* in puppet you manage the desired state of dedicated resources, but for some
  hardning rules you have to run queries on your system to actually get a list
  of resources you want to manage. So if you wanted to comply with the hardning
  rule "every directory that is writeable by everyone should have the
  sticky-bit set", puppet would be able to manage the mode of a directory
  (`ensure => directory, mode => `01777`) but you don't know *which*
  directories you actually want to manage.
* in puppet you can manage a resource only once. So if your hardening module
  ensures that the service `ntp` is running, you cannot manage the service in
  your dedicated `ntp` module.

Becaues of the issues above the hardening modules that I saw simply do quirks
with facts and execs. In my opinion the better approach is the following:

* A hardening module should manage a hardning status, no file or service
  resources. This allows us to manage the resources in the module where they
  actually belong.
* A hardening rule sometimes needs information about the system (like "which
  directories are world-writeable?"). Only two parts run on the agent answer
  that question: Facts and providers. In my opinion facts are not really
  useable for that, so we need a custom provider.
* write a puppet type where you can specify the hardening rule and the desired
  state (`ensure => passed`, `ensure => failed`) and a provider that will run
  the correct hardening rule.

## Write your own hardening rule

To create a new hardening rule, simly drop a file in `lib/harden/rules/`. A
skeleton of a rule looks like this:

````ruby
Harden::Rule.add('my-rule') do
  desc "Make sure /tmp is 1777"

  check "if mode on /tmp is 1777" do
    # ruby code to check that
  end

  fix "change mode on /tmp to 1777" do
    # ruby code to actually do that
  end
end
````

By default a rule is not scored. If you want to classify your rule as scored,
you can pass an optional parameter to the `Harden::Rule.add` method:

````ruby
Harden::Rule.add('my-rule', :scored => true)
````

despite `check` you can also specify a `precheck` block which works the same
way. If the precheck block fails, the hardening rule fails with missing
dependencies and the check block will not run.

A lot of hardening rules are more less similar. You don't have to reinvent the
wheel all the time. Have a look at `lib/util/harden/util.rb` for helper
functions like `execute`, `kernelmodule_loaded?`, `add_mountoptions`, etc.

You can also define templates and refer to a template in a hardening rule,
e.g.

````ruby
# make sure the kernelmodule udf is not loaded
# and disabled
require 'harden/template/kernelmodule'

Harden::Rule.add('cis-1.1.24', :scored => false) do
  template :kernelmodule, :module => 'udf'
end
````

Look into `lib/harden/template` for a list of predefined templates or create
your own.
