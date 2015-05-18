#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <bluetooth/rfcomm.h>
#include <omp.h>

int main(int argc, char **argv)
{
    inquiry_info *ii = NULL;
    int max_rsp, num_rsp;
    int dev_id, sock, len, flags;
    int i;
    char addr[19] = { 0 };
    char jason_addr[19] = { 0 };
    char name[248] = { 0 };

    dev_id = hci_get_route(NULL);
    sock = hci_open_dev( dev_id );
    if (dev_id < 0 || sock < 0) {
        perror("opening socket");
        exit(1);
    }

    len  = 8;
    max_rsp = 255;
    flags = IREQ_CACHE_FLUSH;
    ii = (inquiry_info*)malloc(max_rsp * sizeof(inquiry_info));
    
    printf("Searching for devices\n");
    num_rsp = hci_inquiry(dev_id, len, max_rsp, NULL, &ii, flags);
    if( num_rsp < 0 ) perror("hci_inquiry");

    for (i = 0; i < num_rsp; i++) {
        ba2str(&(ii+i)->bdaddr, addr);
        memset(name, 0, sizeof(name));
        if (hci_read_remote_name(sock, &(ii+i)->bdaddr, sizeof(name), 
            name, 0) < 0)
            strcpy(name, "[unknown]");
        printf("Found device: %s  %s\n", addr, name);
        if(strcmp(name,"Jason-bt00")==0){
            memcpy(jason_addr,addr,19);
        }
    }
    if(strcmp(jason_addr,"")==0){
        printf("Device not found\n");
        return 0;
    }
    // New socket
    int s,status;
    struct sockaddr_rc addr_full = { 0 };
    char buff[100];
    s = socket(AF_BLUETOOTH, SOCK_STREAM & ~O_NONBLOCK, BTPROTO_RFCOMM);
    addr_full.rc_family = AF_BLUETOOTH;
    addr_full.rc_channel = (uint8_t) 1;
    str2ba(jason_addr,&addr_full.rc_bdaddr);

    status = connect(s, (struct sockaddr *)&addr_full, sizeof(addr_full));

    struct timeval t;    
    t.tv_sec = 2;
    t.tv_usec = 0;
    status=setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (const void *)(&t),sizeof(t));   

    if( status < 0 ) 
        perror("uh oh");
    int j=0;
#pragma omp parallel sections
{
#pragma omp section
    {
        int k=0;
        while(1){
            k++;
            sleep(1);
            printf("%d\n",k);
        }
    }
#pragma omp section
    {
    while(1) {
        j++;
        status = recv(s, buff, 16, 0);
        buff[16]=0;
        int i=0;
        unsigned short prev;
        unsigned short cur;
        int bad = 1;
        //printf("%d\n",j);
        for(i=0;i<16;i++)
            //printf("%02x ",buff[i]&0xff);
            if(i&&(buff[i]&0xff)==0xf1 && (buff[i-1]&0xff)==0x00){
                //printf("%02x %02x\n",buff[i]&0xff,buff[i+1]&0xff);
                cur = *(unsigned short *)(buff+1+i);
                if((cur&0xff )== 0x00 && (0xff&prev) == 0xff)
                    bad = 0;
                else if(cur == prev+1)
                    bad = 0;
                else if(cur == prev)
                    bad =2;

                prev = cur;
                break;
            }
        if(bad == 1)
            printf("loss\n");
        //if(bad == 2)
          //  printf("dup\n");
        //printf("\n");
    }
    }
}
    printf("%d\n",status);


    close(s);
    free( ii );
    close( sock );
    return 0;
}


