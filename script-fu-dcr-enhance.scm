(define
    (dcr-enhance-auto-contrast
        img
        layerId
    )
    ; Apply auto contrast script-fu
    (gimp-item-set-name layerId "Script-Fu/Contrast/Auto contrast")
    (gimp-image-insert-layer img layerId 0 0)
    (FU-auto-contrast img layerId TRUE)

    ; Reset the ID of the contrast layer, which is changed due to merging
    (set! layerId (car (gimp-image-get-active-layer img)))
    layerId
)

(define
    (dcr-enhance-wavelet-sharpen
        img
        sourceLayer
        amt
        isVisible
    )
    (let *
        (
            (outputLayer (car (gimp-layer-copy sourceLayer TRUE)))
            (layerTitle (string-append "Filters/Enhance/Wavelet Sharpen (" (number->string amt) " amt)"))
        )

        ; Apply wavelet sharpen plugin
        (gimp-item-set-name outputLayer layerTitle)
        (gimp-image-insert-layer img outputLayer 0 0)
        (plug-in-wavelet-sharpen RUN-NONINTERACTIVE img outputLayer amt 1.0 TRUE)
        (gimp-item-set-visible outputLayer isVisible)
        outputLayer
    )
)

(define
    (script-fu-dcr-enhance
        img
        drawable
    )
    (gimp-image-undo-group-start img)
    (let*
        (
            (contrastLayer (car (gimp-layer-copy drawable TRUE)))
            (sharpenLayerLight)
            (sharpenLayerMedium)
            (sharpenLayerHeavy)
        )

        (set! contrastLayer (dcr-enhance-auto-contrast img contrastLayer))
        (set! sharpenLayerLight (dcr-enhance-wavelet-sharpen img contrastLayer 0.1 TRUE))
        (set! sharpenLayerMedium (dcr-enhance-wavelet-sharpen img contrastLayer 0.5 FALSE))
        (set! sharpenLayerHeavy (dcr-enhance-wavelet-sharpen img contrastLayer 1.0 FALSE))

        ; Reset active layer
        (gimp-image-set-active-layer img sharpenLayerLight)
    )
    (gimp-image-undo-group-end img)
)
(script-fu-register "script-fu-dcr-enhance"     ;func name
    "DCR Enhance"                               ;menu label
    "Provides a series of enhancements to the\
      currently selected layer of the image."   ;description
    "Daniel Rieck"                              ;author
    "copyright 2018, Daniel Rieck"              ;copyright notice
    "May 29, 2018"                              ;date created
    "*"                                         ;image type that the script works on
    SF-IMAGE       "Current image"      0
    SF-DRAWABLE    "Current layer"      0
)
(script-fu-menu-register "script-fu-dcr-enhance" "<Image>/Filters/Enhance/")
