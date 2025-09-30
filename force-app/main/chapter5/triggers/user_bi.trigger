trigger user_bi on User(before insert) {
    ExperienceUtils.SetExperienceLevel(trigger.new, 'Newbie');
}