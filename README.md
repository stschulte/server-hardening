# server-hardening

This script can be used to harden a linux server. It is intended
to be easily extendable to include your own checks.

## How to run
This is a *really* early alpha and the script unterstands no switches right
now so it cannot be configured in any way (except modifying the code of
course). So probably best to not run it at all. You have been warned.

````bash
# Clone repository and set Ruby Librarypath
git clone git@github.com:stschulte/server-hardening.git
cd server-hardening
export RUBYLIB=`pwd`/lib

# Harden your server
bin/harden.rb
````

## A word about Puppet

I developed this as a stand-alone program but I also plan to use the library
in a future puppet module, so you can use puppet to make sure your system is
hardened (and stays that way). But why didn't I start with puppet in the first
place you say?

In my opinion the hardening modules that I have seen so far use vanilla puppet
types to configure your system. Mostly `file`, `file_line`, `service` and
`package` resources. This approach has a few drawpacks:
* in puppet you manage the desired state of dedicated resources. But some
  hardening rules only specify a specific attribute of a resource. As a result
  a puppet hardening module is often more strict than necessary. Example:
  According to the CIS Security Benchmark `/tmp` should be mounted with the
  `noexec` option on RedHat Systems. A puppet module may ensure this with a
  mount resource:

  ````puppet
  mount { '/tmp':
    options => 'noexec',
  }
  ````

  Easy, huh? But what if I want to mount `/tmp` as `tmpfs` and with `size=2G`?
  The above puppet code would simply replace the mountoptions, erasing any
  prior mountsettings (using an augeas resource might be a viable solution
  though)
* in puppet you manage the desired state of dedicated resources, so you have
  to actually *know* which resources you want to manage. But some hardening
  rules require you to run queries first. Imagine you want to comply with the
  hardening rule "every directory that is writeable by everyone should have the
  sticky-bit set"? While puppet can manage the access mode of a directory
  (`ensure => directory, mode => `01777`) you need to know the resources where
  this access mode should be applied.
* in puppet you can manage a resource only once. So if your hardening module
  ensures that the service `ntp` is running, you cannot manage the service in
  your dedicated `ntp` module anymore.

Becaues of the issues above the hardening modules that I looked at simply do
quirks with facts and execs. In my opinion the better approach is the
following:

* A hardening module should manage a hardening status, no file or service
  resources. This allows us to manage the actual resources in the module where
  they belong.
* A hardening rule sometimes needs information about the system (like "which
  directories are world-writeable?"). Only two parts run on the agent and can
  actually answer that question: Facts and providers. In my opinion facts are
  not really useable for that, so a custom provider is the better approach.
* write a puppet type where you can specify the hardening rule and the desired
  state (`ensure => passed`, `ensure => failed`) and a provider that will run
  the correct hardening rule.

## Write your own hardening rule

To create a new hardening rule, simly drop a file in `lib/harden/rules/`. A
skeleton of a rule looks like this:

````ruby
# Create a new rule 'my-rule'
Harden::Rule.add('my-rule') do
  # The description can be seen when you run the hardening script
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
dependencies and the `check` block will not run at all (same goes to the `fix`
block)

A lot of hardening rules do the same kind of check on different objects. You
don't have to reinvent the wheel all the time. Have a look at
`lib/util/harden/util.rb` for helper functions like `execute`,
`kernelmodule_loaded?`, `add_mountoptions`, etc.

You can also define templates and refer to a template in a hardening rule. A
template will automatically create the appropiate `check` and `fix` blocks.
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
