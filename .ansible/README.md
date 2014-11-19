# Propro: Provision like a pro

Propro will always be biased to my needs for my apps and servers. It's not
intended to be a magical unicorn for every use-case, I deploy Ruby apps to
Ubuntu 12.04 and 14.04 x64 on Linode. I typically use Postgres, Redis, Nginx,
and Ruby.

Feel free to use it as an Ansible grab-bag or starting-point if your needs
differ. Also check out [Ansible Galaxy](https://galaxy.ansible.com/) for magic
unicorns, there are some mighty robust/battle-hardened roles on there!

The beauty of Ansible is just how easy it is to re-use roles and tweak
playbooks, don't think you're confined to what I've laid-out here. Feel free
to create your own playbooks for your specific needs. Propro is really just
supposed to be a starting point and collection of roles to build systems the
way that I like them to be built.

## Provisioning A Vagrant VM

1. Copy the Vagrantfile.example and change the private IP and VM name to your
   liking
2. Copy this repo into the `.ansible` (or whatever works for you) directory of
   your Vagrant project, or add it as a submodule.
3. Run `vagrant up` the system should build itself
4. Have a beer or wine or spirit or soda or juice or water to celebrate

## Provisioning A Real World VPS

1. Add your own `inventory` directory, check out the `inventory_example`
   for how this might look.
2. Add and build a VPS in your provider of choice, remember to choose Ubuntu
   12.04, or 14.04 as Propro was only built against those two distributions.
3. Run the `prepare-vps.yml` playbook, this adds the public keys for the GitHub
   users you specified in `admin_authorized_githubbers` variable and disables
   root login and password login.

   ```
   ansible-playbook -k -u root -i inventory/hosts prepare-vps.yml
   ```
4. Now you can run the `site.yml` playbook and provision your servers as the
   admin user that was created above since password-based auth and root-access
   are now disabled.

   ```
   ansible-playbook -K -s -u admin -i inventory/hosts site.yml
   ```

## About The Included Groups

Here is some info about the groups that are included in the example inventory
file and playbook tasks, and what they aim to achieve.

#### `fullstack_servers`

Full stack servers host everything, you can think of this as your "classic" web
server setup where everything is on one machine.

#### `app_servers`

App servers host your Ruby application and Nginx, typically you will have a
load balancer in front of your app servers. In my case I use Linode's
Nodebalancer product, but you could just as easily add a play to provision an
instance with HAProxy and use that as your load balancer. If you're on a VPS and
they offer a load balancing product it's usually a good idea to utilize it since
they are often optimized for that use-case.

#### `worker_servers`

Exactly the same as an app server except replace Puma with Sidekiq. There is
nothing stopping you from running Sidekiq on your app servers, but if you have
the cash to run your workers on separate machines it's really nice to do so.

#### `db_servers`

Hosts PostgreSQL and/or Redis, data is persisted on these servers. They don't
know anything about your app other than that they will accept inbound
connections from your app/worker servers.

#### `db_clients`

This is an aggregate group that consists of all the servers that will need to
talk to the database servers. The private IPs are pulled from these machines and
use to configure the firewall rules on the database machines.

#### `linode` and `digital_ocean`

These groups show you how to apply variables to ranges of machines, in this case
we use them to configure public/private netmasks specific to the two providers.
