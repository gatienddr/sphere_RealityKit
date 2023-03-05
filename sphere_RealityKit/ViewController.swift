//
//  ViewController.swift
//  sphere_RealityKit
//
//  Created by Gatien DIDRY on 05/03/2023.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {

    private var sceneEventUpdateSubscription: Cancellable!

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: ARView
        let arView = ARView(
            frame: view.frame,
            cameraMode: .nonAR,
            automaticallyConfigureSession: false
        )

        // MARK: Background
        let skyboxName = "aerodynamics_workshop_4k"
        let skyboxResource = try! EnvironmentResource.load(named: skyboxName)

        arView.environment.lighting.resource = skyboxResource
        arView.environment.background = .skybox(skyboxResource)

        // MARK: Sphere
        var sphereMaterial = SimpleMaterial()
        sphereMaterial.metallic = MaterialScalarParameter(floatLiteral: 1)
        sphereMaterial.roughness = MaterialScalarParameter(floatLiteral: 0)

        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 1), materials: [sphereMaterial])


        let sphereAnchor = AnchorEntity(world: .zero)
        sphereAnchor.addChild(sphereEntity)
        arView.scene.addAnchor(sphereAnchor)

        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera .fieldOfViewInDegrees = 60

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(cameraEntity)

        arView.scene.addAnchor(cameraAnchor)

        sceneEventUpdateSubscription = arView.scene.subscribe(
            to: SceneEvents.Update.self,
            { _ in
            })

        let cameraDistance: Float = 3
        var currentCameraRotation: Float = 0
        let cameraRotationSpeed: Float = 0.01

        sceneEventUpdateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self, { _ in
            let x = sin(currentCameraRotation) * cameraDistance
            let z = cos(currentCameraRotation) * cameraDistance

            let cameraTranslation = SIMD3<Float>(x,0,z)
            let cameraTransform = Transform(scale: .one, rotation: simd_quatf(), translation: cameraTranslation)
            cameraEntity.transform = cameraTransform
            cameraEntity.look(at: .zero, from: cameraTranslation, relativeTo: nil)
            currentCameraRotation += cameraRotationSpeed
        })


        view.addSubview(arView)
    }


}

