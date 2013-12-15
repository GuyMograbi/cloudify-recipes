
import java.rmi.RemoteException;
import java.util.ArrayList;
import javax.xml.namespace.QName;
import org.apache.axis.client.Stub;
import org.apache.axis.message.SOAPHeaderElement;

import com.cognos.developer.schemas.bibus._3.*;



public class CognosAdminServices {


	private boolean banonymous=false;
	private static ContentManagerService_PortType cmService;
	private Dispatcher_PortType dispatcher;
	private BiBusHeader cmBiBusHeader = null;


	public CognosAdminServices(final String dispatcherHost,final String dispatcherPort) throws Exception
	{
		String dispatcherHostPort = combineHostPort(dispatcherHost,dispatcherPort);
		String dispatcherUrl = buildDispatcherUrl(dispatcherHostPort);
		 
		try {
			 
			ContentManagerService_ServiceLocator cmServiceLocator = new ContentManagerService_ServiceLocator();
			this.cmService = cmServiceLocator.getcontentManagerService(new java.net.URL(dispatcherUrl));

			Dispatcher_ServiceLocator dispatcherLocator = new Dispatcher_ServiceLocator();
			this.dispatcher = dispatcherLocator.getdispatcher(new java.net.URL(dispatcherUrl));
		} catch (Exception e) {
			 
		}
		System.out.println("Connected to: " + dispatcherUrl);
	}

	private static String combineHostPort(String dispatcherHost,String dispatcherPort) {
		String dispatcherHostPort = dispatcherHost + ":" + dispatcherPort;
		return dispatcherHostPort;
	}

	private static String buildDispatcherUrl(String dispatcherHostPort) {
		String dispatcherUrl = "http://" + dispatcherHostPort + "/p2pd/servlet/dispatch";
		return dispatcherUrl;
	}

	public void quickLogon(String namespace, String uid, String pwd) {

		try
		{
			StringBuffer credentialXML = new StringBuffer();

			credentialXML.append("<credential>");
			credentialXML.append("<namespace>").append(namespace).append("</namespace>");
			credentialXML.append("<username>").append(uid).append("</username>");
			credentialXML.append("<password>").append(pwd).append("</password>");
			credentialXML.append("</credential>");

			String encodedCredentials = credentialXML.toString();
			XmlEncodedXML xmlCredentials = new XmlEncodedXML();
			xmlCredentials.set_value(encodedCredentials);

			this.cmService.logon(xmlCredentials,null);

			SOAPHeaderElement temp = ((Stub)this.cmService).getResponseHeader("http://developer.cognos.com/schemas/bibus/3/", "biBusHeader");
			cmBiBusHeader = (BiBusHeader)temp.getValueAsType(new QName ("http://developer.cognos.com/schemas/bibus/3/","biBusHeader"));
			((Stub)this.cmService).setHeader("http://developer.cognos.com/schemas/bibus/3/", "biBusHeader", cmBiBusHeader);
			((Stub)this.dispatcher).setHeader("http://developer.cognos.com/schemas/bibus/3/", "biBusHeader", cmBiBusHeader);
			banonymous=false;
		}
		catch (Exception e) {
			System.out.println("Warning: Named authentication failed. Will try as anonymous.");
			banonymous=true;
		}
	}

	public void closeConnection() {

		if((this.cmService!=null)&&(banonymous==false))
		{
			try {
				this.cmService.logoff();
			} catch (RemoteException e) {

			}
		}
	}

	public void addUserOrGroupToRole(String SearchPath , String RoleSearchPath) throws RemoteException{

		if((this.cmService!=null)&&(banonymous==false))
		{
			BaseClass userresults[] = new BaseClass[] {};
			BaseClass admins[] = new BaseClass[] {};
			BaseClass[] existingMembers;
			ArrayList<BaseClass> members = new ArrayList<BaseClass>();
			Role role = null;


			System.out.println("Searching for user in cognos repository: ");
			userresults = this.cmService.query(
					new SearchPathMultipleObject(SearchPath),
					new PropEnum[] {
						PropEnum.searchPath},
						new Sort[] {},
						new QueryOptions()); 
			if((userresults!=null)&&(userresults.length>0))
			{
				System.out.println(userresults[0].getSearchPath().getValue());
			}

			//Retrieve the capability, including policies
			admins = this.cmService.query(
					new SearchPathMultipleObject(RoleSearchPath),
					new PropEnum[] {
						PropEnum.searchPath,
						PropEnum.members,
						PropEnum.policies,
						PropEnum.defaultName },
						new Sort[] {},
						new QueryOptions());
			role = (Role)admins[0];

			//Store existing members
			if (role.getMembers().getValue() != null)
			{
				existingMembers = role.getMembers().getValue();
				for (BaseClass member : existingMembers)
					if (!member.getSearchPath().getValue().equals("CAMID(\"::Everyone\")") &&
                                           !member.getSearchPath().getValue().equals(userresults[0].getSearchPath().getValue()))
						members.add(member);
			}

			//Add admins to list
			members.add(userresults[0]);

			if((role!=null)&&(userresults.length>0)&&(userresults[0]!=null))
			{				
				// Update the role information in the content store
				role.setMembers(new BaseClassArrayProp());
				role.getMembers().setValue(members.toArray(new BaseClass[members.size()]));
				this.cmService.update(new BaseClass[] { role },new UpdateOptions());

			}
		}
	}


	public void  removeEveryOneFromRole(String SearchPath) throws RemoteException{

		if((this.cmService!=null)&&(banonymous==false))
		{
			BaseClass admins[] = new BaseClass[] {};
			BaseClass[] existingMembers;
			ArrayList<BaseClass> members = new ArrayList<BaseClass>();
			Role role = null;


			//Retrieve the capability, including policies
			admins = this.cmService.query(
					new SearchPathMultipleObject(SearchPath),
					new PropEnum[] {
						PropEnum.searchPath,
						PropEnum.members,
						PropEnum.defaultName },
						new Sort[] {},
						new QueryOptions());
			role = (Role)admins[0];

			//Store existing members
			if (role.getMembers().getValue() != null)
			{
				existingMembers = role.getMembers().getValue();
				for (BaseClass member : existingMembers)
					if (!member.getSearchPath().getValue().equals("CAMID(\"::Everyone\")"))
						members.add(member);
			}

			if(role!=null)
			{				
				// Update the role information in the content store
				role.setMembers(new BaseClassArrayProp());
				role.getMembers().setValue(members.toArray(new BaseClass[members.size()]));
				this.cmService.update(new BaseClass[] { role },new UpdateOptions());

			}
		}
	}
	
	public void setQueryServiceSettingsForAllDispatchers(int minHeap, int maxHeap, String jvmArgs) throws Exception
	{
		if((this.cmService!=null)&&(banonymous==false))
		{
			SearchPathMultipleObject spMulti = new SearchPathMultipleObject("/configuration/*[@objectClass='dispatcher']");
			PropEnum[] props = {PropEnum.searchPath, 
					PropEnum.qsJVMHeapSizeLimit,
					PropEnum.qsInitialJVMHeapSize,
					PropEnum.qsAdditionalJVMArguments, 
					PropEnum.qsManualCubeStart};
			BaseClass[] results = cmService.query(spMulti, props, new Sort[]{}, new QueryOptions() );

			for(int i = 0; i < results.length; i++)
			{
				Dispatcher_Type disp = (Dispatcher_Type) results[i];

				IntProp propMaxHeap = new IntProp();
				propMaxHeap.setValue(maxHeap);
				disp.setQsJVMHeapSizeLimit(propMaxHeap);

				IntProp propMinHeap = new IntProp();
				propMinHeap.setValue(minHeap);
				disp.setQsInitialJVMHeapSize(propMinHeap);

				if (jvmArgs != null) {
					StringProp propJvmArgs = new StringProp();
					propJvmArgs.setValue(jvmArgs);
					disp.setQsAdditionalJVMArguments(propJvmArgs);
				}
			}

			cmService.update(results, new UpdateOptions());
		}
	}
	
	public void restartServices(String hostname) throws RemoteException{
                if((this.cmService!=null)&&(banonymous==false))
                {
                    StringBuffer searchPath = new StringBuffer();
                    searchPath.append("/configuration/dispatcher[@name='http://");
                    searchPath.append(hostname);
                    searchPath.append(":9300/p2pd']/queryService[@name='QueryService']");

                    SearchPathSingleObject spSingle = new SearchPathSingleObject();
                    spSingle.set_value(searchPath.toString());
                    System.out.println("Restarting QueryService...");
                    this.dispatcher.stopService(spSingle, true);
                     this.dispatcher.startService(spSingle);
                }
	}

	
	public static void configureCognos(final String dispatcherHost,final String dispatcherPort, String userName, String passWord, int javaMinHeap, int javaMaxHeap)  {
		
		CognosAdminServices service;
		try {
			service = new CognosAdminServices(dispatcherHost, dispatcherPort);
			service.quickLogon("BLU_LDAP", userName, passWord);
			
			// Assign Roles to Groups.
			
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bluadmin,ou=groups\")",  "CAMID(\"::System Administrators\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:u:uid=bluadmin,ou=people\")", "CAMID(\"::System Administrators\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")", "CAMID(\":Authors\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")", "CAMID(\":Cognos Insight Users\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bluusers,ou=groups\")", "CAMID(\":Cognos Insight Users\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")", "CAMID(\":Consumers\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bluusers,ou=groups\")", "CAMID(\":Consumers\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")", "CAMID(\":Controller Users\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bluusers,ou=groups\")","CAMID(\":Controller Users\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")",  "CAMID(\":Express Authors\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")", "CAMID(\":Mobile Users\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bluusers,ou=groups\")","CAMID(\":Mobile Users\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")", "CAMID(\":Readers\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bluusers,ou=groups\")","CAMID(\":Readers\")");
			service.addUserOrGroupToRole("CAMID(\"BLU_LDAP:g:cn=bludev,ou=groups\")", "CAMID(\":Report Administrators\")");
			service.removeEveryOneFromRole("CAMID(\":Adaptive Analytics Users\")");
			service.removeEveryOneFromRole("CAMID(\":Analysis Users\")");
			service.removeEveryOneFromRole("CAMID(\":Data Manager Authors\")");
			service.removeEveryOneFromRole("CAMID(\":Metrics Authors\")");
			service.removeEveryOneFromRole("CAMID(\":Metrics Users\")");
			service.removeEveryOneFromRole("CAMID(\":Planning Contributor Users\")");
			service.removeEveryOneFromRole("CAMID(\":PowerPlay Users\")");
        		service.removeEveryOneFromRole("CAMID(\":Query Users\")");
			service.setQueryServiceSettingsForAllDispatchers(javaMinHeap, javaMaxHeap, null);
			service.restartServices(dispatcherHost);
			service.closeConnection();
			
			
		} catch (Exception e) {
			System.out.println("\nAn error occurred\n");
			e.printStackTrace();
		}
		
	}
	
	public static void main(String[] args) throws Exception {
		
                String hostName = null;
		String port = null;
		String userName = null;
		String passwd = null;
                int javaminHeap = 1024;;
                int javamaxHeap = 1024;

		for (int i=0; i<args.length; i++)
		{
			if (args[i].compareToIgnoreCase("-c1") == 0) {
				hostName = args[++i];
			} else if (args[i].compareToIgnoreCase("-c2") == 0) {
				port = args[++i];
			} else if (args[i].compareToIgnoreCase("-cu") == 0) {
				userName = args[++i];
			} else if (args[i].compareToIgnoreCase("-cp") == 0) {
				passwd = args[++i];
			} else if (args[i].compareToIgnoreCase("-cminheap") == 0) {
                                javaminHeap = Integer.valueOf(args[++i]);
                        } else if (args[i].compareToIgnoreCase("-cmaxheap") == 0) {
                                javamaxHeap = Integer.valueOf(args[++i]);
                        }
                  
		}
                if (hostName != null && port != null && userName != null && passwd != null && javaminHeap != 0 && javamaxHeap != 0)
                {
                    configureCognos(hostName, port, userName, passwd, javaminHeap , javamaxHeap);
                }
                else 
                { 
     
                }
	}

}
