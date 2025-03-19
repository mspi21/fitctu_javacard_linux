try:
    from dotenv import dotenv_values
    from smartcard.System import readers
    from smartcard.util import toHexString
except ModuleNotFoundError:
    print('Error: The required packages were not found! Make sure you activated your virtual environment.')
    print('    To activate the virtual environment, run `source .venv/bin/activate`.')
    if __name__ == '__main__':
        exit(1)

from dotenv import dotenv_values
from smartcard.System import readers
from smartcard.util import toHexString
import time

# Establish a connection to the first reader that has a card inserted.
def establish_context():
    r = readers()
    if not r:
        raise Exception("No smartcard readers found.")

    for reader in r:
        connection = reader.createConnection()
        try:
            connection.connect()
            return connection
        except:
            continue

    raise Exception("No card detected in any of the readers.")

def send_apdu(aid, apdu):
    card = establish_context()
    try:
        _, sw1, sw2 = card.transmit([0x00, 0xA4, 0x04, 0x00] + [len(aid)] + aid)
        assert (sw1, sw2) == (0x90, 0x00), 'Applet selection failed. Make sure the AID is correct.'
        return card.transmit(apdu)
    finally:
        card.disconnect()

def parse_hex_data(data):
    return list(bytes.fromhex(data))

def parse_apdu(argv):
    cla, ins, p1, p2 = map(lambda s: int(s, 16), sys.argv[1:5])
    lc, data, le = None, [], None

    opt = sys.argv[5:]
    if len(opt) == 0:
        pass
    elif len(opt) == 1:
        le = int(opt[0], 16)
    elif len(opt) == 2:
        lc = int(opt[0], 16)
        data = parse_hex_data(opt[1])
    elif len(opt) == 3:
        lc = int(opt[0], 16)
        data = parse_hex_data(opt[1])
        le = int(opt[2], 16)
    else:
        raise Exception('Wrong number of arguments. (Did you put spaces between data?)')

    if lc is not None and len(data) != lc:
        raise Exception('Lc is not consistent with data.')

    return cla, ins, p1, p2, lc, data, le

def status_word_id(sw1, sw2):
    known_sws = {
        (0x6A, 0x84): 'SW_FILE_FULL',
        (0x6F, 0x00): 'SW_UNKNOWN',
        (0x6E, 0x00): 'SW_CLA_NOT_SUPPORTED',
        (0x6D, 0x00): 'SW_INS_NOT_SUPPORTED',
        (0x6C, 0x00): 'SW_CORRECT_LENGTH_00',
        (0x6B, 0x00): 'SW_WRONG_P1P2',
        (0x6A, 0x86): 'SW_INCORRECT_P1P2',
        (0x6A, 0x83): 'SW_RECORD_NOT_FOUND',
        (0x6A, 0x82): 'SW_FILE_NOT_FOUND',
        (0x6A, 0x81): 'SW_FUNC_NOT_SUPPORTED',
        (0x6A, 0x80): 'SW_WRONG_DATA',
        (0x69, 0x99): 'SW_APPLET_SELECT_FAILED',
        (0x69, 0x86): 'SW_COMMAND_NOT_ALLOWED',
        (0x69, 0x85): 'SW_CONDITIONS_NOT_SATISFIED',
        (0x69, 0x84): 'SW_DATA_INVALID',
        (0x69, 0x83): 'SW_FILE_INVALID',
        (0x69, 0x82): 'SW_SECURITY_STATUS_NOT_SATISFIED',
        (0x67, 0x00): 'SW_WRONG_LENGTH',
        (0x61, 0x00): 'SW_BYTES_REMAINING_00',
        (0x90, 0x00): 'SW_NO_ERROR'
    }

    if (sw1, sw2) in known_sws.keys():
        return known_sws[(sw1, sw2)]
    else:
        return None

def print_apdu_data(data, end):
    print('data=[', end='')
    for i, x in enumerate(data):
        if i != 0:
            print(end=' ')
        print(f'{x:02x}', end='')
    print(']', end=end)

def print_apdu_req(cla, ins, p1, p2, lc, data, le):
    print(f'> CLA={cla:02x} INS={ins:02x} P1={p1:02x} P2={p2:02x} ', end='')
    print(f'Lc={lc:02x} ' if lc is not None else 'Lc= ', end='')
    print_apdu_data(data, end=' ')
    print(f'Lc={le:02x}' if le is not None else 'Le=')

def print_apdu_res(data, sw1, sw2):
    print('< ', end='')
    print_apdu_data(data, end=' ')
    print(f'SW1={sw1:02x} SW2={sw2:02x}', end='')
    status = status_word_id(sw1, sw2)
    if status is not None:
        print(f' ({status})', end='')
    print()

if __name__ == "__main__":
    import sys
    usage = (
        'Usage: send_apdu.py CLA INS P1 P2 [Lc] [data] [Le]\n' +
        '    All values are expected in hexadecimal encoding.'
    )

    config = dotenv_values("config.env")
    assert 'APPLET_AID' in config.keys()
    aid = list(map(lambda s: int(s, 0), config['APPLET_AID'].split(':')))

    try:
        cla, ins, p1, p2, lc, data, le = parse_apdu(sys.argv)
        print_apdu_req(cla, ins, p1, p2, lc, data, le)
    except Exception as e:
        print(f'Invalid APDU: {e}')
        print(usage)
        exit(1)

    try:
        response, sw1, sw2 = send_apdu(aid, (
                [cla, ins, p1, p2]
                    + ([lc] if lc is not None else [])
                    + (data if data is not None else [])
                    + ([le] if le is not None else [])
            ))
        print_apdu_res(response, sw1, sw2)
    except Exception as e:
        print(f'Error: {e}')
