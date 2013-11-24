/*******************************************************************************
* Copyright (c) 2012 GigaSpaces Technologies Ltd. All rights reserved
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*       http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*******************************************************************************/
service {
    extend "../../../services/chef-server"
	compute {
		// Chef server does NOT support 32bit !!!
        template "MEDIUM_UBUNTU"
    }
  lifecycle{
	postStart {
            if(binding.variables["chefRepos"]){
		chefRepos.each(){ repo -> 
			chef_loader = ChefLoader.get_loader(repo.repo_type)
               		chef_loader.initialize()
	                chef_loader.fetch(repo.url, repo.inner_path)
                	chef_loader.upload()
		}
            } else if (binding.variables["chefRepo"]) {		
                chef_loader = ChefLoader.get_loader(chefRepo.repo_type)
                chef_loader.initialize()
                chef_loader.fetch(chefRepo.url, chefRepo.inner_path)
                chef_loader.upload()
            } else {
                ChefLoader.get_loader().initialize()
            }
        }
  }
}
