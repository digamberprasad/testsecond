@RestResource(urlMapping='/BECommunityPassword/*')
global class BECommunityPasswordManagement {
    @HttpPost
    global static Boolean changeCommunityUserPassword(String userId,String password) {
        Boolean setSuccessfully = true;
        try {
            System.setPassword(userId, password);
        } catch(Exception ex) {
            System.debug('Puneet Password '+ex);
            setSuccessfully = false;
        }
        return setSuccessfully;

    }
}