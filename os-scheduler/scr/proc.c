// filepath: src/proc.c
void
scheduler(void)
{
  struct proc *p;
  struct proc *highp;

  for(;;){
    sti();
    acquire(&ptable.lock);
    highp = 0;

    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE) continue;
      if(highp == 0 || p->priority < highp->priority)
        highp = p;
    }

    if(highp){
      p = highp;
      proc = p;
      switchuvm(p);
      p->state = RUNNING;
      swtch(&cpu->scheduler, proc->context);
      switchkvm();
      proc = 0;
    }
    release(&ptable.lock);
  }
}
