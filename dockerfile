#!/bin/bash

# Pastikan Anda berada di root direktori proyek (os-scheduler)

echo "Memulai setup xv6 dengan prioritas..."

# 1. Membuat direktori dan file yang diperlukan
mkdir -p src scripts tests

# 2. Membuat file src/proc.h
cat > src/proc.h <<EOL
struct proc {
  // ... (bagian lain dari struct proc)
  int priority; // nilai prioritas, makin kecil makin penting
  // ...
};
EOL

# 3. Membuat file src/proc.c (bagian scheduler saja)
cat > src/proc.c <<EOL
#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

// ... (bagian lain dari proc.c)

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

// ... (bagian lain dari proc.c)

void display_gantt_chart() {
    struct proc *p;
    for(p = proc; p < &proc[NPROC]; p++) {
        if(p->state == TERMINATED) {
            printf("P%d: [%d-%d] ", p->pid, p->start_time, p->completion_time);
        }
    }
    printf("\n");
}
EOL

# 4. Membuat file user/user.h (bagian setpriority)
cat > user/user.h <<EOL
// ... (bagian lain dari user.h)
int setpriority(int pid, int priority);
EOL

# 5. Membuat file user/usys.S (bagian setpriority)
cat > user/usys.S <<EOL
# ... (bagian lain dari usys.S)
SYSCALL(setpriority)
EOL

# 6. Membuat file kernel/syscall.h (bagian setpriority)
cat > kernel/syscall.h <<EOL
// ... (bagian lain dari syscall.h)
#define SYS_setpriority 24
EOL

# 7. Membuat file kernel/syscall.c (bagian setpriority)
cat > kernel/syscall.c <<EOL
// ... (bagian lain dari syscall.c)
extern int sys_setpriority(void);
[SYS_setpriority] sys_setpriority,
EOL

# 8. Membuat file kernel/sysproc.c (implementasi setpriority)
cat > kernel/sysproc.c <<EOL
#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"
#include "traps.h"
#include "syscall.h"
#include "sysfunc.h"

// ... (bagian lain dari sysproc.c)

int
sys_setpriority(void)
{
  int pid, newprio;
  if(argint(0, &pid) < 0 || argint(1, &newprio) < 0)
    return -1;

  struct proc *p;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->priority = newprio;
      break;
    }
  }
  release(&ptable.lock);
  return 0;
}
EOL

# 9. Membuat file src/setprio.c
cat > src/setprio.c <<EOL
#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[]) {
  if(argc != 3){
    printf(2, "Usage: setprio pid priority\n");
    exit();
  }
  int pid = atoi(argv[1]);
  int priority = atoi(argv[2]);
  if(setpriority(pid, priority) < 0){
    printf(2, "Failed to set priority\n");
  }
  exit();
}
EOL

# 10. Membuat file src/Makefile (tambahkan setprio)
cat > src/Makefile <<EOL
# ... (bagian lain dari Makefile)
UPROGS=\
  _setprio\
# ...
EOL

# 11. Membuat file scripts/run.sh
mkdir -p scripts
cat > scripts/run.sh <<EOL
#!/bin/bash
echo "Compiling and Running Scheduler..."
cd src
make
./xv6
EOL
chmod +x scripts/run.sh

# 12. Membuat file tests/run_tests.sh
mkdir -p tests
cat > tests/run_tests.sh <<EOL
#!/bin/bash
# filepath: tests/run_tests.sh

echo "Test: Priority Scheduling"
./setprio 3 1
./setprio 4 5
# tambahkan test lain
EOL

echo "Setup xv6 dengan prioritas selesai."
