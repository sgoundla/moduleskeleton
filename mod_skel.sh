#/bin/bash

        printf "Enter Module Name  "
        read  mod_name
        echo "Module name is $mod_name"


        cd /users/sgoundla/Phase2
        sudo rm -rf $mod_name

        puppet module generate cisco-$mod_name

#       sudo git init --bare --shared=group $mod_name
        sudo git init $mod_name

        cd $mod_name
        sudo git add .
        sudo git commit -m "Initial checkin to $mod_name (or whatever meaningful)"
        cd ..

        git clone --bare $mod_name

        rsync -avzH sgoundla@kicker-dev-1:/usr/local/gitconf/config ${mod_name}.git
        rsync -az sgoundla@kicker-dev-1:/usr/local/gitconf/hooks ${mod_name}.git
        echo "$mod_name" > ${mod_name}.git/description

        rsync -az ${mod_name}.git sgoundla@dc-tools-dev1:/opt/git/enterprise-os/puppet/linux/modules

        uname=sgoundla
        host=dc-tools-dev1

        echo "#/bin/bash;
        cd /opt/git/enterprise-os/puppet/linux/modules;
        sudo chgrp -R ciscolinux ${mod_name}.git;
        sudo chmod -R g+rwX ${mod_name}.git;
        sudo find ${mod_name}.git/ -type d -exec chmod g+s '{}' +;

        sudo ./setup-deploy-branch-hooks.sh remove
        sudo ./setup-deploy-branch-hooks.sh setup
        exit" > ch_script.sh

        scp ch_script.sh sgoundla@dc-tools-dev1:/auto/linux/sandbox/sgoundla/.

        ssh -t sgoundla@dc-tools-dev1 'cd /auto/linux/sandbox/sgoundla/; sudo sh ch_script.sh'

        cd /users/sgoundla/test_Phase2

        rm -rf $mod_name
        git clone sgoundla@dc-tools-dev1:/opt/git/enterprise-os/puppet/linux/modules/$mod_name

        cd $mod_name
        cp ../entos_test_srini/Gemfile .
        bundle install
        mkdir -p spec/acceptance/nodesets
        cp ../entos_test_srini/spec/acceptance/nodesets/* spec/acceptance/nodesets
        cp ../entos_test_srini/spec/spec_helper.rb spec/
        cp ../entos_test_srini/spec/classes/init_spec.rb spec/classes/init_spec.rb

        cd spec/
        sed -e "s/Module_name/$mod_name/" spec_helper.rb > x1; mv x1 spec_helper.rb
        cd classes/
        sed -e "s/repo_name/$mod_name/" init_spec.rb > x1; mv x1 init_spec.rb

        cd ../..
        git add .
        git commit -m "Updating file skeleton for $mod_name"
        git push


        echo "Git Repository for $mod_name Successfully Created"
