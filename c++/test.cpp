#include <stdio.h>
#include <time.h>

int main ()
{
    const time_t rawtime = (const time_t)1552360776;

    struct tm dt;
    char timestr[30];
    char buffer[30];

    localtime_r(&rawtime, &dt);
    strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%y", &dt);
    sprintf(buffer, "%s", timestr); 
    printf("\n%s,%d, %u,%d\n", buffer, sizeof(time_t), sizeof(long),time(NULL));
}
