public class ChatterLightningOut {
 @AuraEnabled
    public static ConnectApi.FeedElementPage displayChatter(){
        ConnectApi.FeedElementPage fep=
            ConnectApi.ChatterFeeds.getFeedElementsFromFeed('0DB4E0000004CD5WAM',ConnectAPI.FeedType.News,'me');
    return fep;
    }
    @AuraEnabled
    public static ConnectApi.ChatterLike likeFeedElement(String feedElementId) {
        ConnectApi.ChatterLike flike =
        ConnectApi.ChatterFeeds.likeFeedElement('0DB4E0000004CD5WAM', feedElementId);
        return flike;
    }
}