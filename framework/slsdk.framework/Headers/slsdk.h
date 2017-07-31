#ifndef __ORAY_SLSDK_H__
#define __ORAY_SLSDK_H__

#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#define SLAPI __stdcall
#include <windows.h>
#else
#define SLAPI
#endif

#ifdef __cplusplus
extern "C" {
#endif
    
    /*
     * @brief SLAPI�汾��
     */
#define SLAPI_VERSION 1
    
    /*
     * @brief �����ƶ˻���
     */
    typedef unsigned long SLCLIENT;
    
    /*
     * @brief ���ƶ˻���
     */
    typedef unsigned long SLREMOTE;
    
    /*
     * @brief �����ƶ˻Ự
     */
    typedef unsigned int SLSESSION;
    
    /*
     * @brief ��Ч�����ƶ˻���
     */
#define SLCLIENT_INVAILD 0
    
    /*
     * @brief ��Ч���ƶ˻���
     */
#define SLREMOTE_INVAILD 0
    
    /*
     * @brief ��Ч�Ự
     */
#define SLSESSION_INVAILD (-1)
    
    /**
     * @brief SLAPI�����
     */
    enum SLERRCODE
    {
        //�ɹ�
        SLERRCODE_SUCCESSED = 0,
        
        //�ڲ�����
        SLERRCODE_INNER = 1,
        
        //δ��ʼ��
        SLERRCODE_UNINITIALIZED = 2,
        
        //��������
        SLERRCODE_ARGS = 3,
        
        //��֧��
        SLERRCODE_NOTSUPPORT = 4,
        
        //��������ʧ��
        SLERRCODE_CONNECT_FAILED = 5,
        
        //�������ӳ�ʱ
        SLERRCODE_CONNECT_TIMEOUT = 6,
        
        //�Ự������
        SLERRCODE_SESSION_NOTEXIST = 7,
        
        //�Ự���
        SLERRCODE_SESSION_OVERFLOW = 8,
        
        //�Ự���ʹ���
        SLERRCODE_SESSION_WRONGTYPE = 9,
        
        //OPENID����
        SLERRCODE_EXPIRED = 10,
    };
    
    /**
     * @brief �Ựѡ��
     */
    enum ESLSessionOpt
    {
        eSLSessionOpt_window = 1,					//!< ����
        eSLSessionOpt_callback = 2,				//!< �ص�
        eSLSessionOpt_deviceSource = 3,			//!< �豸Դ
        eSLSessionOpt_connected = 4,				//!< ����״̬
        eSLSessionOpt_desktopctrl_listener = 5,	//!< ����״̬
        eSLSessionOpt_ipport = 6,					//!< ����״̬
    };
    
    /**
     * @brief �Ự�¼�
     */
    enum ESLSessionEvent
    {
        eSLSessionEvent_OnConnected = 1, 		//!< ���ӳɹ�
        eSLSessionEvent_OnDisconnected = 2, 	//!< �Ͽ�����
        eSLSessionEvent_OnDisplayChanged = 3,	//!<
    };
    
    /*
     * @brief �Ự�ص��¼���������
     */
    typedef void (SLAPI *SLSESSION_CALLBACK)(SLSESSION session, ESLSessionEvent evt, unsigned long custom);
    
    /**
     * @brief �Ự�ص�����
     */
    typedef struct tagSLSESSION_CALLBACK_PROP
    {
        SLSESSION_CALLBACK pfnCallback;	//!< �ص�����
        unsigned long nCustom;			//!< �Զ�������
        
    } SLSESSION_CALLBACK_PROP;
    
    /*
     * @brief �Ự����
     */
    enum ESLSessionType
    {
        eSLSessionType_Desktop,		//!< Զ������Ự
        eSLSessionType_File,		//!< Զ���ļ��Ự
        eSLSessionType_Cmd,			//!< Զ��CMD�Ự
        eSLSessionType_Sound,		//!< Զ�������Ự
        eSLSessionType_DataTrans,	//!< ���ݴ���Ự
        eSLSessionType_DesktopView,	//!< Զ������鿴�Ự
        eSLSessionType_Port,		//!< Զ������鿴�Ự
    };
    
    enum SLProxyType
    {
        SLProxy_None,
        SLProxy_HTTP,
        SLProxy_Socks5,
        SLProxy_Socks4,
        SLProxy_IE,
    };
    
    /**
     * ��������
     */
    struct SLPROXY_INFO
    {
        char ip[20];
        char port[10];
        char user[20];
        char pwd[20];
        char domain[200];
        SLProxyType type;	//ProxyType
    };
    
    
    /*
     * @brief ��ʼ��SLAPI����
     * @desc ��ʹ���κ�SLAPI֮ǰ���ȵ��ô�API����ʼ������SLAPI��������������ֻ��Ҫ����һ�μ���
     * @return �Ƿ��ʼ���ɹ�
     */
    bool SLAPI SLInitialize();
    
    /*
     * @brief �˳�SLAPI����
     * @desc ���������������˳�ǰ���ã����ͷ�SLAPI������ʹ�õ���Դ
     * @return �Ƿ��˳��ɹ�
     */
    bool SLAPI SLUninitialize();
    
    /*
     * @brief ��ȡ���Ĵ�����
     * @return ����SLERRCODE������
     */
    SLERRCODE SLAPI SLGetLastError();
    
    /*
     * @brief �������Ĵ�����
     * @param errCode ������
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetLastError(SLERRCODE errCode);
    
    /*
     * @brief ��ȡ��������ϸ˵��
     * @return ��ϸ��Ϣ����������벻�����򷵻ء�δ֪����
     */
    const char* SLAPI SLGetErrorDesc(SLERRCODE errCode);
    
    
    
    
    /************************************************************************/
    /* �����ƶ����API                                                      */
    /************************************************************************/
    /**
     * @brief �����ƶ��¼�
     */
    enum SLCLIENT_EVENT
    {
        SLCLIENT_EVENT_ONCONNECT = 0,	//!< ���ӳɹ�
        SLCLIENT_EVENT_ONDISCONNECT = 1,	//!< �Ͽ�����
        SLCLIENT_EVENT_ONLOGIN = 2,			//!< ��¼�ɹ�
        SLCLIENT_EVENT_ONLOGINFAIL = 3,		//!< ��¼ʧ��
    };
    
    /*
     * @brief ����һ�������ƶ˻���
     * @return ���ر����ƶ˻���ֵ���������ʧ���򷵻�SLCLIENT_INVAILD
     */
    SLCLIENT SLAPI SLCreateClient(void);
    
    /*
     * @brief ����һ�������ƶ˻���
     * @param client Ҫ���ٵı����ƶ˻���
     */
    bool SLAPI SLDestroyClient(SLCLIENT client);
    
    /*
     * @brief �����ƶ˻ص��¼�
     * @param client �����ƶ˻���
     * @param event �¼�
     * @param custom �û��Զ������
     */
    typedef void (SLAPI *SLCLIENT_CALLBACK)(SLCLIENT client, SLCLIENT_EVENT event, unsigned long custom);
    
    /*
     * @brief ���ñ����ƶ��¼��ص�����
     * @param client �����ƶ˻���
     * @param pfnCallback �ص�������ַ
     * @param custom �û��Զ���������ص�ʱ�ڲ�����Ὣ�˲���һ���ص�
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetClientCallback(SLCLIENT client, SLCLIENT_CALLBACK pfnCallback, unsigned long custom);
    
    /*
     * @brief �����ƶ˵�¼������
     * @param client �����ƶ˻���
     * @param pstrOpenID �����ߵ�ID��
     * @param pstrOpenKey ������ID��Ӧ����֤��
     * @return �Ƿ��¼�ɹ�
     */
    bool SLAPI SLClientLoginWithOpenID(SLCLIENT client, const char* pstrOpenID, const char* pstrOpenKey);
    
    /** \brief Short name for SLClientLoginWidthOpenID
     *
     */
    bool SLAPI SLLoginWidthOpenID(SLCLIENT client, const char* pstrOpenID, const char* pstrOpenKey);
    
    
    /*
     * @brief �����ƶ˵�¼������
     * @param client �����ƶ˻���
     * @param szAddr ��������ַ
     * @param szLic lincense
     * @return �Ƿ��¼�ɹ�
     */
    bool SLAPI SLClientLoginWithLicense(SLCLIENT client, const char* szAddr, const char* szLic);
    
    /*
     * @brief �����ƶ��Ƿ��¼��
     * @param client �����ƶ˻���
     */
    bool SLAPI SLClientIsOnLoginned(SLCLIENT client);
    /*
     * @brief �ڱ����ƶ˻����д���һ���Ự
     * @param client �����ƶ˻���
     * @return �Ựֵ���������ʧ�ܣ��򷵻�SLSESSION_INVAILD
     */
    SLSESSION SLAPI SLCreateClientSession(SLCLIENT client, ESLSessionType eType);
    
    /*
     * @brief ����һ���Ự
     * @param client �����ƶ˻���
     * @param session �Ự
     * @return �Ƿ����ٳɹ�
     */
    bool SLAPI SLDestroyClientSession(SLCLIENT client, SLSESSION session);
    
    
    /*
     * @brief ���ô���
     * @param client �����ƶ˻���
     * @param proxy ��������
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetClientProxy(SLCLIENT client, const SLPROXY_INFO& proxy);
    
    /*
     * @brief ö�ٱ��ض˵�ǰ�ж��ٸ��Ự
     * @param client �����ƶ˻���
     * @param pSessionArray �Ự���飨���������
     * @param nArraySize ���鳤��
     * @return һ���ж��ٸ��Ự
     */
    unsigned int SLAPI SLEnumClientSession(SLCLIENT client, SLSESSION* pSessionArray, unsigned int nArraySize);
    
    /*
     * @brief ��ȡ�����ƶ����ӵ�ַ
     * @remark �����ڵ�¼�ɹ����ٻ�ȡ���ܻ�ȡ��ȷ��ֵ�������ص��¼�SLCLIENT_EVENT_ONLOGIN��������á�ͨ����ֵ�����ƶ˲���ʹ�øûỰ�ķ���
     * @return ��ַ
     */
    const char* SLAPI SLGetClientAddress(SLCLIENT client);
    
    /*
     * @brief ��ȡ�����ƶ�ĳ���Ự��ֵ
     * @remark ͨ����ֵ�����ƶ˲���ʹ�øûỰ�ķ���
     * @return �Ựֵ������Ự�������򷵻�NULL
     */
    const char* SLAPI SLGetClientSessionName(SLCLIENT client, SLSESSION session);
    
    /*
     * @brief �����ƶ�ĳ���Ự��������
     * @param client �����ƶ˻���
     * @param session �Ự
     * @param lpData ���͵�����
     * @param nLen ���͵����ݳ���
     * @return ���͵��ֽ���
     * @remark Ŀǰֻ������DataTrans���͵ĻỰ
     */
    unsigned long SLAPI SLClientSessionSendData(SLCLIENT client, SLSESSION session, const char* lpData, unsigned long nLen);
    
    /*
     * @brief �����ƶ�ĳ���Ự��������
     * @param client �����ƶ˻���
     * @param session �Ự
     * @param lpData �������ݵĻ�����
     * @param nLen ׼�����յ����ݳ���
     * @return ʵ�ʽ��յ����ֽ���
     * @remark Ŀǰֻ������DataTrans���͵ĻỰ
     */
    unsigned long SLAPI SLClientSessionRecvData(SLCLIENT client, SLSESSION session, char* lpData, unsigned long nLen);
    
    /*
     * @brief ��ȡ�����ƶ�ĳ���Ựĳ������ֵ
     * @return �Ƿ��ȡ�ɹ�
     */
    bool SLAPI SLGetClientSessionOpt(SLCLIENT client, SLSESSION session, ESLSessionOpt eOpt, char* pOptVal, unsigned int nOptLen);
    
    /*
     * @brief ���ñ����ƶ�ĳ���Ựĳ������ֵ
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetClientSessionOpt(SLCLIENT client, SLSESSION session, ESLSessionOpt eOpt, const char* pOptVal, unsigned int nOptLen);
    
    /*
     * @brief ����WEB����
     * @return �Ƿ�ɹ�
     */
    bool SLAPI SLStartWebServer(SLCLIENT client, unsigned int nPort=0);
    
    /*
     * @brief �ر�WEB����
     * @return �Ƿ�ɹ�
     */
    bool SLAPI SLStopWebServer(SLCLIENT client);
    
    /*
     * @brief web������˷���������true��ʾ�Ѿ������˵�ǰ�¼����ײ㽫�����ٴ���
     * @param client �����ƶ˻���
     * @param data ָ�����ݵ�ָ��
     * @param size ���ݳ���
     */
    typedef bool (SLAPI *SLWEB_FILTER)(SLCLIENT client,const void* data,unsigned int size);
    
    /*
     * @brief ����web������˷���
     * @param client �����ƶ˻���
     * @param filter ����ָ��
     */
    bool SLAPI SlSetWebServerFilter(SLCLIENT client,SLWEB_FILTER filter);
    
    /*
     * @brief ��web�ͻ��˷�������
     * @param client �����ƶ˻���
     * @param data ָ�����ݵ�ָ��
     * @param size ���ݳ���
     */
    bool SLAPI SlWebServerSend(SLCLIENT client,const void* pdata,unsigned int size);
    
    /************************************************************************/
    /* ���ƶ����API                                                        */
    /************************************************************************/
    /**
     * @brief �����ƶ��¼�
     */
    enum SLREMOTE_EVENT
    {
        SLREMOTE_EVENT_ONCONNECT = 0, 		//!< ���ӳɹ�
        SLREMOTE_EVENT_ONDISCONNECT, 			//!< �Ͽ�����
        SLREMOTE_EVENT_ONDISCONNECT_FOR_FULL, //!< �Ͽ�����(��Ϊ����������)
    };
    
    /*
     * @brief ����һ�����ƶ˻���
     * @return ���ر����ƶ˻���ֵ���������ʧ���򷵻�SLREMOTE_INVAILD
     */
    SLREMOTE SLAPI SLCreateRemote(void);
    
    /*
     * @brief ����һ�����ƶ˻���
     * @param remote ���ƶ˻���
     * @return �Ƿ����ٳɹ�
     */
    bool SLAPI SLDestroyRemote(SLREMOTE remote);
    
    /*
     * @brief ���ô���
     * @param client �����ƶ˻���
     * @param remote ���ƶ˻���
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetRemoteProxy(SLREMOTE remote, const SLPROXY_INFO& proxy);
    
    /*
     * @brief �����ƶ˻ص��¼�
     * @param remote �����ƶ˻���
     * @param event �¼�
     * @param custom �û��Զ������
     */
    typedef void (SLAPI *SLREMOTE_CALLBACK)(SLREMOTE remote, SLSESSION session, SLREMOTE_EVENT event, unsigned long custom);
    
    /*
     * @brief ���������ƶ��¼��ص�����
     * @param remote �����ƶ˻���
     * @param pfnCallback �ص�������ַ
     * @param custom �û��Զ���������ص�ʱ�ڲ�����Ὣ�˲���һ���ص�
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetRemoteCallback(SLREMOTE remote, SLREMOTE_CALLBACK pfnCallback, unsigned long custom);
    
    /*
     * @brief ���������ƶ˻Ự
     * @param remote ���ƶ˻���
     * @param eType �Ự����
     * @param pstrAddress Զ�̱����ƶ˵�ַ
     * @param pstrSession Զ������Ự��
     * @return �Ự
     */
    SLSESSION SLAPI SLCreateRemoteSession(SLREMOTE remote, ESLSessionType eType, const char* pstrAddress, const char* pstrSession);
    
    /*
     * @brief ���������ƶ˿ջỰ(������)
     * @param remote ���ƶ˻���
     * @param eType �Ự����
     * @remark ��SLCreateRemoteSession��ͬ���Ǵ���һ���ջỰ�����������ӣ����������ʹ��SLConnectRemoteSession�����ӻỰ
     * @return �Ự
     */
    SLSESSION SLAPI SLCreateRemoteEmptySession(SLREMOTE remote, ESLSessionType eType);
    
    /*
     * @brief �������ض˻Ự
     * @param remote ���ƶ˻���
     * @param session �Ự
     * @param pstrAddress Զ�̱����ƶ˵�ַ
     * @param pstrSession Զ������Ự��
     * @return �Ự
     */
    bool SLAPI SLConnectRemoteSession(SLREMOTE remote, SLSESSION session, const char* pstrAddress, const char* pstrSession);
    
    /*
     * @brief ����һ���Ự
     * @param remote ���ƶ˻���
     * @param session �Ự
     * @return �Ƿ����ٳɹ�
     */
    bool SLAPI SLDestroyRemoteSession(SLREMOTE remote, SLSESSION session);
    
    /*
     * @brief �����ƶ�ĳ���Ự��������
     * @param remote �����ƶ˻���
     * @param session �Ự
     * @param lpData ���͵�����
     * @param nLen ���͵����ݳ���
     * @return ���͵��ֽ���
     * @remark Ŀǰֻ������DataTrans���͵ĻỰ
     */
    unsigned long SLAPI SLRemoteSessionSendData(SLREMOTE remote, SLSESSION session, const char* lpData, unsigned long nLen);
    
    /*
     * @brief �����ƶ�ĳ���Ự��������
     * @param remote �����ƶ˻���
     * @param session �Ự
     * @param lpData �������ݵĻ�����
     * @param nLen �������ݻ���������
     * @return ʵ�ʽ��յ����ֽ���
     * @remark Ŀǰֻ������DataTrans���͵ĻỰ
     */
    unsigned long SLAPI SLRemoteSessionRecvData(SLREMOTE remote, SLSESSION session, char* lpData, unsigned long nLen);
    
    /*
     * @brief ��ȡ�����ƶ�ĳ���Ựĳ������ֵ
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLGetRemoteSessionOpt(SLREMOTE remote, SLSESSION session, ESLSessionOpt eOpt, char* pOptVal, unsigned int nOptLen);
    
    /*
     * @brief ���������ƶ�ĳ���Ựĳ������ֵ
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetRemoteSessionOpt(SLREMOTE remote, SLSESSION session, ESLSessionOpt eOpt, const char* pOptVal, unsigned int nOptLen);
    
    /*
     * @brief ����Զ�����洰�ڵĴ�С
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetDesktopSessionPos(SLREMOTE remote, SLSESSION session, int x,int y,int width,int height);
    
    /*
     * @brief Show desktop window
     * @return �Ƿ����óɹ�
     */
    bool SLAPI SLSetDesktopSessionVisible( SLREMOTE remote, SLSESSION session );
    
    
    /*
     * @brief	Get original desktop size
     * @return	
     */
    bool SLAPI SLGetDesktopSessionOriginSize( SLREMOTE remote, SLSESSION session, int* width, int* height );
    
    
#ifdef __cplusplus
}
#endif


#endif //__ORAY_SLSDK_H__
