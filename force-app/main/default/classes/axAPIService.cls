/**
* @File Name : axAPIService.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 27, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 27, 2025 |   | Initial Version
**/

public class axAPIService {
	@AuraEnabled
	public static void LightningStudio(){
		System.debug('Lightning Studio');
	}
}