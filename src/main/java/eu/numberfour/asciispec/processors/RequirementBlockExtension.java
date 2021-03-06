package eu.numberfour.asciispec.processors;

/**
 * Registration class for the {@link RequirementBlockProcessor} processor.
 *
 * If you rename or move this class, do not forget to update the
 * META-INF/services/org.asciidoctor.extension.spi.ExtensionRegistry file!
 */
public class RequirementBlockExtension extends ProcessorExtension {
	@Override
	protected void register(JavaExtensionRegistry registry) {
		registry.block(RequirementBlockProcessor.class);
	}
}
