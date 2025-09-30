trigger user_ai on User (after insert) {
    ChatterGroupUtils.PostWelcomeUsersToGroupFuture(Trigger.newMap.keySet());
}