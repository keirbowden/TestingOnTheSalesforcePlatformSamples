public class ExperienceUtils {
    public static void SetExperienceLevel(List<User> users, String value) {
        if ( (null!=users) && (null!=value) ) {
            for (User usr : users) {
                if (null!=usr) {
                    usr.Experience_Level__c=value;
                }
            }
        }
    }
}
