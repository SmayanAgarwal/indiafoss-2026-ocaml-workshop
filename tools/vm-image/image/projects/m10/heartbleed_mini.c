/* Heartbleed in miniature, structured like the real OpenSSL handler.
 * receive_heartbeat() reads a request buffer, interprets the first
 * byte as the heartbeat type, the next two as a big-endian payload
 * length, and echoes `payload_len` bytes back.
 *
 * The bug: it trusts the attacker's length field and never checks it
 * against the bytes actually received, so memcpy reads past the
 * request into adjacent server memory and ships whatever is there
 * back to the attacker.
 *
 *   cc -o heartbleed_mini heartbleed_mini.c && ./heartbleed_mini
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define n2s(p) (((p)[0] << 8) | (p)[1])   /* read a 2-byte big-endian length */

/* Parse `request` as a heartbeat and return a freshly allocated
 * response carrying `payload_len` echoed bytes; *resp_len gets the
 * length. `received` is how many bytes really arrived. */
unsigned char *receive_heartbeat(unsigned char *request, int received,
                                 int *resp_len) {
    /* unsigned char hbtype = request[0]; */
    int payload_len = n2s(request + 1);     /* attacker-controlled, 0..65535 */
    unsigned char *payload = request + 3;   /* the payload starts here */

    /* THE BUG: we never check payload_len against `received`. The real
     * OpenSSL fix is one line:
     *     if (1 + 2 + payload_len > received) return NULL;          */
    (void)received;

    unsigned char *response = malloc(payload_len);
    memcpy(response, payload, payload_len); /* copies past the real payload */
    *resp_len = payload_len;
    return response;
}

int main(void) {
    /* One server buffer holds the incoming request. Just past the
     * 1-byte payload, still inside the server's memory, sits a secret
     * the attacker never sent. */
    unsigned char *buf = malloc(64);
    memset(buf, 0, 64);
    buf[0] = 1;                   /* heartbeat request type            */
    buf[1] = 0; buf[2] = 48;      /* claimed payload length = 48       */
    buf[3] = 'h';                 /* the 1 payload byte really received */
    strcpy((char *)buf + 16, "TLS-PRIVATE-KEY");  /* secret, next door */

    int received = 4;             /* type + length + 1 payload byte    */
    int resp_len;
    unsigned char *response = receive_heartbeat(buf, received, &resp_len);

    printf("request carried %d real payload byte, claimed %d\n",
           received - 3, resp_len);
    printf("echoed back: ");
    for (int i = 0; i < resp_len; i++) {
        unsigned char c = response[i];
        putchar(c >= 32 && c < 127 ? c : '.');
    }
    putchar('\n');
    return 0;
}
