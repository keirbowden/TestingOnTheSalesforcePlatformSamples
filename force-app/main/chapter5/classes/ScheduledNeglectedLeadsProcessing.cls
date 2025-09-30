public class ScheduledNeglectedLeadsProcessing implements Schedulable {
    private static Integer MIN_SCOPE_SIZE=1;
    private static Integer MAX_SCOPE_SIZE=2000;

    private Integer scopeSize;

    public ScheduledNeglectedLeadsProcessing() {
        this(300);
    }

    public ScheduledNeglectedLeadsProcessing(Integer scopeSize) {
        if ( (null==scopeSize) || (MIN_SCOPE_SIZE>scopeSize) || (MAX_SCOPE_SIZE<scopeSize) ) {
            throw new NeglectedLeadsException('scopeSize must be between ' + 
                                              MIN_SCOPE_SIZE + ' and ' + 
                                              MAX_SCOPE_SIZE);
        }

        this.scopeSize=scopeSize;
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(new MarkNeglectedLeadsBatch(), scopeSize);
    }
}