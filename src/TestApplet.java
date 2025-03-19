package testpackage;

import javacard.framework.*;

public class TestApplet extends Applet
{
    protected byte[] HELLO = new byte[] {'H', 'e', 'l', 'l', 'o'};

    public static void install(byte[] bArray, short bOffset, byte bLength)
    {
        (new TestApplet()).register();
    }

    protected TestApplet()
    {
    }

    public void process(APDU apdu)
    {
        if (selectingApplet())
            ISOException.throwIt(ISO7816.SW_NO_ERROR);

        if (getCla(apdu) != (byte)0x80)
            ISOException.throwIt(ISO7816.SW_CLA_NOT_SUPPORTED);

        switch (getIns(apdu))
        {
            case 0x2a:
                apdu.setOutgoing();
                apdu.setOutgoingLength((short)HELLO.length);
                apdu.sendBytesLong(HELLO, (short)0, (short)HELLO.length);
                ISOException.throwIt(ISO7816.SW_NO_ERROR);
                break;

            default:
                ISOException.throwIt(ISO7816.SW_INS_NOT_SUPPORTED);
                break;
        }
    }

    protected static byte getCla(APDU apdu)
    {
        return apdu.getBuffer()[ISO7816.OFFSET_CLA];
    }

    protected static byte getIns(APDU apdu)
    {
        return apdu.getBuffer()[ISO7816.OFFSET_INS];
    }

    protected static byte getP1(APDU apdu)
    {
        return apdu.getBuffer()[ISO7816.OFFSET_P1];
    }

    protected static byte getP2(APDU apdu)
    {
        return apdu.getBuffer()[ISO7816.OFFSET_P2];
    }
}

